$LOAD_PATH << File.dirname(__FILE__)

require 'getoptlong'
require 'optparse'
require 'rdoc/usage'
require 'osx/cocoa'
require 'yaml'

class CommandlineParser

  include OSX
  include Singleton

  attr_accessor :source                   # NSURL
  attr_accessor :output                   # String
  attr_accessor :paperSize                # NSSize
  attr_accessor :paginate                 # boolean
  attr_accessor :margin                   # float
  attr_accessor :stylesheetMedia          # String
  attr_accessor :printBackground          # boolean
  attr_accessor :paperOrientation         # NSPrintingOrientation
  attr_accessor :horizontallyCentered     # boolean
  attr_accessor :verticallyCentered       # boolean
  attr_accessor :cachingPolicy            # NSURLRequestCachePolicy
  attr_accessor :timeout                  # NSTimeInterval (float, seconds?)
  attr_accessor :saveDelay                # NSTimeInterval (float, seconds?)
  attr_accessor :enablePlugins            # boolean
  attr_accessor :ignoreHttpErrors         # boolean
  attr_accessor :username                 # String
  attr_accessor :password                 # String
  attr_accessor :debug                    # boolean

  attr_accessor :opts                     # OptionParser

  def configure_defaults

    # @source = [NSURL fileURLWithPath:@"/dev/stdin"];
    # @output = @"/dev/stdout";

    generic_printer = NSPrinter.printerWithType("Generic PostScript Printer")
    @paperSize = generic_printer.pageSizeForPaper('A4')
    @paginate = true
    @margin = -1.0
    @stylesheetMedia = ""
    @printBackground = false
    @paperOrientation = NSPortraitOrientation
    @horizontallyCentered = false
    @verticallyCentered = false
    @cachingPolicy = NSURLRequestUseProtocolCachePolicy
    @timeout = 3600.0
    @saveDelay = 0.0
    @enablePlugins = false
    @ignoreHttpErrors = false
    @username = ""
    @password = ""
    @debug = false
  
  end

  def parse_commandline_optparse(args)

    configure_defaults

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: wkpdf [options]"
      opts.separator ""

      opts.separator "Mandatory arguments:"

      opts.on(:REQUIRED, "--source URL|file",
        "URL or file to be converted to PDF (required argument)") do |arg|
        @source = parseSourcePathOrURL(arg)
      end

      opts.on(:REQUIRED, "--output file",
        "filename for the PDF (required argument)") do |arg|
        @output = parseOutputPath(arg)
      end

      opts.separator "Options:"

      opts.on(:REQUIRED, "--format",
        "select paper format (valid values are e.g. A4, A5, A3, Legal, Letter, Executive) CAUTION: these values are case-sensitive") do |arg|
        @paperSize = parsePaperSize(arg)
      end

      opts.on(:NONE, "--portrait",
        "use portrait paper orientation") do
         @paperOrientation = NSPortraitOrientation
      end

      opts.on(:NONE, "--landscape",
        "use landscape paper orientation") do
         @paperOrientation = NSLandscapeOrientation
      end

      opts.on(:NONE, "--hcenter",
        "center output horizontally") do
        @horizontallyCentered = true
      end

      opts.on(:NONE, "--vcenter",
        "center output vertically") do
        @verticallyCentered = true
      end

      opts.on(:REQUIRED, "--caching yes|no",
        "retrieve website from cache if available (default: yes)") do |arg|
        if (arg == "no") then
          @cachingPolicy = NSURLRequestUseProtocolCachePolicy
        else
          @cachingPolicy = NSURLRequestUseProtocolCachePolicy
        end
      end

      opts.on(:REQUIRED, "--timeout N",
        "set timeout to N seconds, default: no timeout\n") do |arg|
        @timeout = Float(arg)
      end

      opts.on(:REQUIRED, "--margin size",
        "set paper margin in points (same margin for all margins") do |arg|
        @margin = Float(arg)
      end

      opts.on(:REQUIRED, "--stylesheet-media media",
        "set the CSS media value (default: 'screen')") do |arg|
        @stylesheetMedia = arg
      end

      opts.on(:REQUIRED, "--print-background yes|no",
        "display background images (default: no)") do |arg|
        @printBackground = true if (arg == "yes")
      end

      opts.on(:REQUIRED, "--paginate yes|no",
        "enable pagination of output (default: yes), output page is resized to fit content when paginate=no") do |arg|
        @paginate = (arg == "yes")
      end

      opts.on(:REQUIRED, "--ignore-http-errors yes|no",
        "generate PDF even if server error occur (e.g. server returns 404 Not Found errors.)") do |arg|
        @ignoreHttpErrors = (arg == "yes")
      end

      opts.on(:REQUIRED, "--username user",
        "authenticate with this username user") do |arg|
        @username = arg
      end

      opts.on(:REQUIRED, "--password pwd",
        "authenticate with this username user") do |arg|
        @password = arg
      end

      opts.on(:REQUIRED, "--enable-plugins yes|no",
        "enable plugins (default: no)") do |arg|
        @enablePlugins = (arg == "yes")
      end

      opts.on(:REQUIRED, "--save-delay time",
        "wait for time seconds after page is loaded before generating the PDF") do |arg|
        @saveDelay = Float(arg)
      end

      opts.on_tail(:NONE, "-v", "--version", "print version number") do
        version_file = "#{File.dirname(__FILE__)}/../VERSION.yml"
        v = YAML::load(File.open( version_file ))
        puts "wkpdf version: #{v[:major]}.#{v[:minor]}.#{v[:patch]}\n"
        NSApplication.sharedApplication.terminate(nil)
      end

      opts.on_tail(:NONE, "--debug", "print debug output") do
        @debug = true
      end

      opts.on_tail(:NONE, "-h", "--help", "show help on options") do
        puts opts
        NSApplication.sharedApplication.terminate(nil)
      end
      
      opts.parse!(args)
    end
  end

# "  --caching arg     set caching policy (valid values are: yes, no) default is yes\n"
# "  --timeout arg     set timeout in seconds, default: no timeout\n"

  def CommandlineParser.usage()
    usage = @opts
    usage += "\n\n"
    usage += "For further information refer to http://plessl.github.com/wkpdf"
    return usage
  end

  def parseSourcePathOrURL(arg)
    argAsString = NSString.stringWithUTF8String(arg)
    path = argAsString.stringByExpandingTildeInPath
    fm = NSFileManager.defaultManager
    if fm.fileExistsAtPath(path) then
      url = NSURL.fileURLWithPath(path)
    else
      url = NSURL.URLWithString(argAsString)
    end

    # check URL validity
    supportedSchemes = NSArray.arrayWithObjects("http", "https", "ftp", "file", nil)
    scheme = url.scheme
    if scheme.nil? || (supportedSchemes.indexOfObject(scheme.lowercaseString) == NSNotFound) then
      puts "#{argAsString} is neither a filename nor an URL with a supported scheme (http,https,ftp,file)\n"
       NSApplication.sharedApplication.terminate(nil)
    end

    return url.absoluteString
  end

  def parseOutputPath(arg)
    argAsString = NSString.stringWithUTF8String(arg)
    path = argAsString.stringByExpandingTildeInPath
    return path
  end

  def parsePaperSize(arg)
    paperName = NSString.stringWithUTF8String(arg)
    generic_printer = NSPrinter.printerWithType("Generic PostScript Printer")
    size = generic_printer.pageSizeForPaper('A4')
    if ((size.width == 0.0) || (size.height == 0.0)) then
      puts "#{paperName} is not a valid paper format\n"
      NSApplication.sharedApplication.terminate(nil)
    end
    return size
  end

end
