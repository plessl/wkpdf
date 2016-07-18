//
//  commandline_parser.swift
//  wkpdf-swift
//
//  Created by Joe Devietti on 7/1/16.
//
//

import Foundation
import Cocoa

enum PageOrientationError: ErrorType {
  case InvalidPageOrientation
}

enum PageOrientation: String {
  case Landscape = "landscape"
  case Portrait = "portrait"
  
  func getNSPaperOrientation() throws -> NSPaperOrientation {
    switch self {
    case .Landscape:
      return NSPaperOrientation.Landscape
    case .Portrait:
      return NSPaperOrientation.Portrait
    default:
      throw PageOrientationError.InvalidPageOrientation
    }
  }
}

/* TODO: Xcode 7.3.1 hangs sometimes when trying to index this code */
let paper_sizes = [ // values are (width,height) in points
  "letter"      : (612,792),
  "lettersmall" : (612,792),
  "tabloid"     : (792,1224),
  "ledger"      : (1224,792),
  "legal"       : (612,1008),
  "statement"   : (396,612),
  "executive"   : (540,720),
  "a0"          : (2384,3371),
  "a1"          : (1685,2384),
  "a2"          : (1190,1684),
  "a3"          : (842,1190),
  "a4"          : (595,842),
  "a4small"     : (595,842),
  "a5"          : (420,595),
  "b4"          : (729,1032),
  "b5"          : (516,729),
  "folio"       : (612,936),
  "quarto"      : (610,780),
  "10x14"       : (720,1008),
  "custom:WxH"  : (-1,-1)
]
//let paper_sizes = [ "a4": (595,842), "letter" : (612,792) ]

class CommandlineParser {

  private let cli = CommandLine()
  
  var output : NSURL?
  var source : NSURL?
  var paperSize : NSSize?
  var cachingPolicy : NSURLRequestCachePolicy = NSURLRequestCachePolicy.UseProtocolCachePolicy
  var margins : (Float,Float,Float,Float)?
  
  let help = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Print usage information")
  let version = BoolOption(shortFlag: "v", longFlag:"version", helpMessage: "Print the version and exit")
  let debug = BoolOption(shortFlag: "d", longFlag: "debug", helpMessage:"Print debug output")
  
  private let _output = StringOption(shortFlag: "o", longFlag: "output", required: true, helpMessage: "Output PDF filename")
  private let _source = StringOption(shortFlag: "s", longFlag: "source", helpMessage: "URL or filename (supported protocols: http, https, ftp, file), if not present read from stdin")
  
  let paper_orientation = EnumOption<PageOrientation>(longFlag: "orientation", helpMessage: "Paper orientation, either portrait (default) or landscape")
  private let paper = StringOption(longFlag: "paper", helpMessage: "Paper size, one of \(paper_sizes.keys.joinWithSeparator(" | ")). Default is a4")
  let noHorizontallyCentered = BoolOption(longFlag: "no-hcenter", helpMessage: "Do not center horizontally")
  let verticallyCentered = BoolOption(longFlag: "vcenter", helpMessage: "Center vertically")
  let no_paginate = BoolOption(longFlag: "no-paginate", helpMessage: "Disable pagination")
  private let _margins = MultiStringOption(shortFlag: "m", longFlag: "margins", helpMessage: "Paper margins in points (T R B L) (V H) or (M)")

  private let no_caching = BoolOption(longFlag: "no-caching", helpMessage: "Disable loading from cache if possible")
  let timeout = DoubleOption(longFlag: "timeout", helpMessage: "Set timeout to N seconds, 3600s by default")
  
  let stylesheet_media = StringOption(longFlag: "stylesheet-media", helpMessage: "Set the CSS media value, screen by default")
  let user_stylesheet = StringOption(longFlag: "user-stylesheet", helpMessage: "URL or path of stylesheet to use")
  let user_script = StringOption(longFlag: "user-script", helpMessage: "URL or path of script to use")
  let print_background = BoolOption(longFlag: "print-background", helpMessage: "Display background images")
  
  let ignore_http_errors = BoolOption(longFlag: "ignore-http-errors", helpMessage:"Generate PDF despite, e.g., a 404 error")
  let username = StringOption(longFlag: "username", helpMessage:"Authenticate with username")
  let password = StringOption(longFlag: "password", helpMessage:"Authenticate with password")
  let enable_plugins = BoolOption(longFlag: "enable-plugins", helpMessage:"Enable plugins")
  let disable_javascript = BoolOption(longFlag: "disable-javascript", helpMessage:"Disable javascript")
  let save_delay = DoubleOption(longFlag: "save-delay", helpMessage:"Wait N seconds after loading to generate PDF")
  let screen_width = IntOption(longFlag: "screen-width", helpMessage:"Screen width for responsive design, 1 by default")
  
  init() {
    cli.addOptions(help, version, debug, _output, _source, paper_orientation, paper, noHorizontallyCentered, verticallyCentered, no_paginate, _margins, no_caching, timeout, stylesheet_media, user_stylesheet, user_script, print_background, ignore_http_errors, username, password, enable_plugins, disable_javascript, save_delay, screen_width)
  }
  
  func parse() {
    do {
      try cli.parse()
    } catch {
      cli.printUsage(error)
      exit(EX_USAGE)
    }
    
    // set default flag values
    if !_source.wasSet { _source.setValue(["/dev/stdin"]) }
    if !paper_orientation.wasSet { paper_orientation.setValue(["portrait"]) }
    if !paper.wasSet { paper.setValue(["a4"]) }
    if !timeout.wasSet { timeout.setValue(["3600"]) }
    if !stylesheet_media.wasSet { stylesheet_media.setValue(["screen"]) }
    if !user_stylesheet.wasSet { user_stylesheet.setValue([""]) }
    if !user_script.wasSet { user_script.setValue([""]) }
    if !save_delay.wasSet { save_delay.setValue(["0"]) }
    if !screen_width.wasSet { screen_width.setValue(["1"]) }
    
    if help.value {
      cli.printUsage()
      exit(EX_OK)
    }
    if version.value {
      print("wkpdf version " + VERSION)
      exit(EX_OK)
    }
    
    output = parseOutputPath(_output.value!)
    source = parseSourcePathOrURL(_source.value!)
    
    if debug.value {
      print("Reading from \(source) and writing to \(output)")
    }
    
    cachingPolicy = no_caching.value ? NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData :
      NSURLRequestCachePolicy.UseProtocolCachePolicy
    
    // set the paper size
    let ps = paper.value!
    if ps.hasPrefix("custom:") { // custom size
      let suffix = ps.substringFromIndex(ps.startIndex.advancedBy(7))
      let dims = suffix.splitByCharacter("x")
      assert(2 == dims.count)
      paperSize = NSMakeSize(CGFloat((dims[0] as NSString).floatValue), CGFloat((dims[1] as NSString).floatValue))
      
    } else if paper_sizes.keys.contains(ps.lowercaseString) { // named size
      let (width,height) = paper_sizes[ps.lowercaseString]!
      paperSize = NSMakeSize(CGFloat(width), CGFloat(height))
      
    } else { // unsupported size
      print("unrecognized paper size\nUse one of: \(paper_sizes.keys.joinWithSeparator(" | "))")
      exit(EX_USAGE)
    }
    
    if _margins.wasSet {
      let f = _margins.value!.map({e in (e as NSString).floatValue})
      switch _margins.value!.count {
      case 4:
        margins = (f[0], f[1], f[2], f[3])
        break;
      case 2:
        margins = (f[0], f[1], f[0], f[1])
        break;
      case 1:
        margins = (f[0], f[0], f[0], f[0])
        break;
      default:
        print("Malformed margins option")
        exit(EX_USAGE)
      }
    }
    
  }
  
  func parseSourcePathOrURL(arg: String) -> NSURL {
    let argAsString = NSString(UTF8String:arg)!
    let path = argAsString.stringByExpandingTildeInPath
    let fm = NSFileManager.defaultManager()
    var url : NSURL? = nil
    if fm.fileExistsAtPath(path) {
      url = NSURL.fileURLWithPath(path)
    } else {
      url = NSURL(string: argAsString as String)
    }
  
    // check URL validity
    let supportedSchemes : [String] = ["http", "https", "ftp", "file"]
    let scheme = url!.scheme
    if !supportedSchemes.contains(scheme.lowercaseString) {
      print("\(argAsString) is neither a filename nor an URL with a supported scheme (http,https,ftp,file)")
      exit(EX_USAGE)
    }
  
    return url!
  }
  
  func parseOutputPath(arg: String) -> NSURL {
    return NSURL(fileURLWithPath: arg)
  }
  
}



