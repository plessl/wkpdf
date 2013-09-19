$:.unshift File.dirname(__FILE__)

begin
  require 'osx/cocoa'
rescue LoadError
  puts "Cannot load RubyCocoa library"
  puts "wkpdf requires that RubyCocoa is installed, which is shipped by default since"
  puts "Mac OS X 10.5. If you use Mac OS X 10.4, you have to install RubyCocoa"
  puts "yourself from http://rubycocoa.sourceforge.net/HomePage"
  exit
end
include OSX
require 'controller'
require 'commandline_parser'

module WKPDF

  class AppDelegate < ::NSObject
    def applicationDidFinishLaunching(aNotification)
      # nothing
    end
  end
  
  def self.
    wkpdf_version
    version_file = "#{File.dirname(__FILE__)}/../VERSION.yml"
    v = YAML::load(File.open( version_file ))
    return "#{v[:major]}.#{v[:minor]}.#{v[:patch]}"
  end

  def self.main

    OSX::require_framework('/System/Library/Frameworks/WebKit.framework')


    OSX::NSApplication.sharedApplication # create NSApp object

    app_delegate = AppDelegate.alloc.init
    ::NSApp.setDelegate(app_delegate)

    parser = CommandlineParser.instance
    parser.parse

    # use 1x1 size: when pagination is turned off, the view should grow to the 
    # required size, if turned on, the view should use the page size. 
    webView = ::WebView.alloc.initWithFrame_frameName_groupName(NSMakeRect(0,0,1,1), "myFrame", "myGroup");
    
    # Parenting webView with a window fixes issue #19
    window = ::NSWindow.alloc.initWithContentRect_styleMask_backing_defer(
            NSMakeRect(0,0,parser.screenWidth.to_i(),1),
            NSBorderlessWindowMask,
            NSBackingStoreNonretained, false)
    window.setContentView(webView)

    webPrefs = ::WebPreferences.standardPreferences
    webPrefs.setLoadsImagesAutomatically(true)
    webPrefs.setAllowsAnimatedImages(true)
    webPrefs.setAllowsAnimatedImageLooping(false)
    webPrefs.setJavaEnabled(false)
    webPrefs.setPlugInsEnabled(parser.enablePlugins)
    webPrefs.setJavaScriptEnabled(parser.enableJavascript)
    webPrefs.setJavaScriptCanOpenWindowsAutomatically(false)
    webPrefs.setShouldPrintBackgrounds(parser.printBackground)
    webPrefs.setUserStyleSheetEnabled(false)

    if parser.userStylesheet != "" then
      webPrefs.setUserStyleSheetEnabled(true)
      webPrefs.setUserStyleSheetLocation(parser.userStylesheet)
      puts "setting user style sheet to #{parser.userStylesheet}\n" if parser.debug
    end

    controller = Controller.alloc.initWithWebView(webView)
    webView.setFrameLoadDelegate(controller)
    webView.setResourceLoadDelegate(controller)
    webView.setApplicationNameForUserAgent("wkpdf/" + wkpdf_version)
    webView.setPreferences(webPrefs)
    webView.setMaintainsBackForwardList(false)

    if parser.stylesheetMedia != "" then
      webView.setMediaStyle(parser.stylesheetMedia)
    end

    pool = ::NSAutoreleasePool.alloc.init

    puts "wkpdf started\n" if parser.debug
    request = ::NSURLRequest.requestWithURL_cachePolicy_timeoutInterval(
    parser.source, parser.cachingPolicy, parser.timeout)

    # TODO: detect timeout and terminate if timeout occured

    webView.mainFrame.loadRequest(request)
    ::NSRunLoop.currentRunLoop.run
    webView.release

    pool.release
    exit 0

  end
  
end
