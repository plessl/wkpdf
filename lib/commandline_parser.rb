require 'rdoc/usage'
require 'osx/cocoa'
require 'yaml'
require 'rubygems'
require 'trollop'

class CommandlineParser

  include OSX
  include Singleton

  attr_accessor :source                   # NSURL
  attr_accessor :output                   # NSURL
  attr_accessor :paperSize                # NSSize
  attr_accessor :paginate                 # boolean
  attr_accessor :margins                  # [float, float, float, float]
  attr_accessor :stylesheetMedia          # String
  attr_accessor :userStylesheet           # NSURL
  attr_accessor :userScript               # NSURL
  attr_accessor :printBackground          # boolean
  attr_accessor :paperOrientation         # NSPrintingOrientation
  attr_accessor :horizontallyCentered     # boolean
  attr_accessor :verticallyCentered       # boolean
  attr_accessor :cachingPolicy            # NSURLRequestCachePolicy
  attr_accessor :timeout                  # NSTimeInterval (float, seconds?)
  attr_accessor :saveDelay                # NSTimeInterval (float, seconds?)
  attr_accessor :enablePlugins            # boolean
  attr_accessor :enableJavascript         # boolean
  attr_accessor :ignoreHttpErrors         # boolean
  attr_accessor :screenWidth              # integer
  attr_accessor :username                 # String
  attr_accessor :password                 # String
  attr_accessor :debug                    # boolean
  
  def parse()

    paper_sizes = {
      "letter"      => [612,792],
      "lettersmall" => [612,792],
      "tabloid"     => [792,1224],
      "ledger"      => [1224,792],
      "legal"       => [612,1008],
      "statement"   => [396,612],
      "executive"   => [540,720],
      "a0"          => [2384,3371],
      "a1"          => [1685,2384],
      "a2"          => [1190,1684],
      "a3"          => [842,1190],
      "a4"          => [595,842],
      "a4small"     => [595,842],
      "a5"          => [420,595],
      "b4"          => [729,1032],
      "b5"          => [516,729],
      "folio"       => [612,936],
      "quarto"      => [610,780],
      "10x14"       => [720,1008],
      "custom:WxH"  => ["INVALID", "INVALID"]
    }
    orientations = {
      'landscape' => NSLandscapeOrientation,
      'portrait' => NSPortraitOrientation,
    }
    v = YAML::load_file(File.join(File.dirname(__FILE__), '../VERSION.yml'))
    opts = Trollop::options do
      version "wkpdf #{v[:major]}.#{v[:minor]}.#{v[:patch]}"
      banner "Usage: wkpdf [options]"
      opt :output, "Output PDF filename", :required => true, :type => :string, :short => 'o'
      opt :source, "URL or filename (supported protocols: http, https, ftp, file), if not present read from stdin", :required => false, :type => :string, :short => 's', :default => '/dev/stdin'
      opt :paper, "Paper size (#{paper_sizes.keys.join(' | ')})", :default => 'a4'
      opt :orientation, "(#{orientations.keys.join(' | ')})", :default => 'portrait'
      opt :hcenter, "Center horizontally", :short => 'c', :default => true
      opt :vcenter, "Center vertically", :default => false
      opt :paginate, 'Enable pagination', :default => true
      opt :margins, 'Paper margins in points (T R B L) (V H) or (M)', :short => 'm', :type => :integers
      opt :caching, 'Load from cache if possible', :default => true
      opt :timeout, 'Set timeout to N seconds', :default => 3600.00
      opt :stylesheet_media, 'Set the CSS media value', :default => 'screen' 
      opt :user_stylesheet, 'URL or path of stylesheet to use', :type => :string
      opt :user_script, 'URL or path of script to use', :type => :string
      opt :print_background, 'Display background images', :default => false
      opt :ignore_http_errors, "Generate PDF despite, e.g., a 404 error", :default => false
      opt :username, 'Authenticate with username', :type => :string
      opt :password, 'Authenticate with password', :type => :string
      opt :enable_plugins, 'Enable plugins', :default => false
      opt :enable_javascript, 'Enable javascript', :default => true
      opt :save_delay, "Wait N seconds after loading to generate PDF", :default => 0.0
      opt :screen_width, "Screen width for responsive design", :default => 1
      opt :version, 'Print the version and exit', :short => 'v'
      opt :help, 'Show this message', :short => 'h'
      opt :debug, 'Print debug output', :default => false, :short => 'd'
      banner ""
      banner "Margins and custom paper sizes are measured in points (72 points = 1 inch.)"
      banner "Further information: http://plessl.github.com/wkpdf"
      banner ""
    end
    
    @output = parseOutputPath(opts[:output])
    @source = parseSourcePathOrURL(opts[:source])
    @userStylesheet = opts[:user_stylesheet] ?
      parseSourcePathOrURL(opts[:user_stylesheet]) : ''
    @userScript = opts[:user_script] ?
      parseSourcePathOrURL(opts[:user_script]) : ''
    
    unless orientations.keys.include?(opts[:orientation])
      Trollop::die :orientation, "Unrecognized page orientation\nUse one of: " + orientations.keys.join(', ')
      NSApplication.sharedApplication.terminate(nil)
    end
    @paperOrientation = orientations[opts[:orientation]]
    
    @cachingPolicy = opts[:caching] ?
      NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalAndRemoteCacheData
    
    opts[:paper] = opts[:paper].downcase
    paper_sizes[opts[:paper]] = [ $~[1], $~[2] ] if opts[:paper] =~ /custom:(\d+)x(\d+)/
      
    unless paper_sizes.has_key?(opts[:paper])
      Trollop::die :paper, "unrecognized paper size\nUse one of: " + paper_sizes.keys.join(', ')
      NSApplication.sharedApplication.terminate(nil)
    end
    dimensions = paper_sizes[opts[:paper]]
    @paperSize = NSMakeSize(dimensions[0], dimensions[1])
    
    @margins = opts[:margins] || [:auto, :auto, :auto, :auto]
    @margins = @margins * 4 if @margins.length == 1
    @margins = [@margins[0], @margins[1]] * 2 if @margins.length == 2

    unless @margins.length == 4
      Trollop::die :margins, 'Malformed margins option'
      NSApplication.sharedApplication.terminate(nil)
    end
    
    [:debug, :timeout, :paginate, :username, :password].each do |k|
      instance_variable_set "@#{k}", opts[k]
    end
    @horizontallyCentered = opts[:hcenter]
    @verticallyCentered = opts[:vcenter]
    @stylesheetMedia = opts[:stylesheet_media]
    @printBackground = opts[:print_background]
    @ignoreHttpErrors = opts[:ignore_http_errors]
    @enablePlugins = opts[:enable_plugins]
    @enableJavascript = opts[:enable_javascript]
    @saveDelay = opts[:save_delay]
    @screenWidth = opts[:screen_width]
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

    return url
  end

  def parseOutputPath(arg)
    absolute_path = File.expand_path(arg)
    return NSString.stringWithUTF8String(absolute_path)
  end

end
