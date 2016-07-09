//
//  main.swift
//  wkpdf-swift
//
//  Created by Joe Devietti on 7/1/16.
//
//

import Foundation
import Cocoa
import WebKit

let VERSION = "0.8.0"

NSApplication.sharedApplication()

// TODO: this doesn't appear to be needed in the Swift version
//var app_delegate = AppDelegate.alloc.init
//::NSApp.setDelegate(app_delegate)

// parse commandline params
let parser = CommandlineParser()
parser.parse()

// use 1x1 size: when pagination is turned off, the view should grow to the
// required size, if turned on, the view should use the page size.
var webView = WebView.init(frame: NSMakeRect(0, 0, 1, 1), frameName: "myFrame", groupName: "myGroup")

// Parenting webView with a window fixes issue #19
var window = NSWindow.init(contentRect: NSMakeRect(0,0,CGFloat(parser.screen_width.value!),1), styleMask: NSBorderlessWindowMask, backing: NSBackingStoreType.Nonretained, defer: false)
window.contentView = webView

var webPrefs = WebPreferences.standardPreferences()
webPrefs.loadsImagesAutomatically = true
webPrefs.allowsAnimatedImages = true
webPrefs.allowsAnimatedImageLooping = false
webPrefs.javaEnabled = false
webPrefs.plugInsEnabled = parser.enable_plugins.value
webPrefs.javaScriptEnabled = !parser.disable_javascript.value
webPrefs.javaScriptCanOpenWindowsAutomatically = false
webPrefs.shouldPrintBackgrounds = parser.print_background.value
webPrefs.userStyleSheetEnabled = false

if parser.user_stylesheet.value! != "" {
  webPrefs.userStyleSheetEnabled = true
  webPrefs.userStyleSheetLocation = NSURL(string: parser.user_stylesheet.value!)
  if parser.debug.value {
    print("setting user style sheet to \(parser.user_stylesheet.value)")
  }
}

let controller = Controller(webview: webView)
webView.frameLoadDelegate = controller
webView.resourceLoadDelegate = controller
webView.applicationNameForUserAgent = "wkpdf/" + VERSION
webView.preferences = webPrefs
webView.setMaintainsBackForwardList(false)

if parser.stylesheet_media.value! != "" {
  webView.mediaStyle = parser.stylesheet_media.value!
}

if parser.debug.value {
  print("wkpdf started")
  print("stylesheet media: \(parser.stylesheet_media.value!)")
}

let request = NSURLRequest(URL: parser.source!, cachePolicy: parser.cachingPolicy, timeoutInterval: Double(parser.timeout.value!))

// TODO: detect timeout and terminate if timeout occured

webView.mainFrame.loadRequest(request)
NSRunLoop.currentRunLoop().run()

print("All done!")

exit(EX_OK)