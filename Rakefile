require 'rubygems'
require 'rake'
require 'echoe'

require File.join(File.dirname(__FILE__), 'lib', 'version')

WKPDF_VERSION = Wkpdf::VERSION::STRING

Echoe.new('wkpdf', WKPDF_VERSION) do |p|
  p.summary        = "Render HTML to PDF using WebKit."
  p.description    = "wkpdf renders HTML to PDF using WebKit on Mac OS X. wkpdf is "
  p.description    += "implemented in RubyCocoa."
  p.version        = WKPDF_VERSION
  p.platform       = "darwin-*-*"
  p.url            = "http://github.com/plessl/wkpdf"
  p.author         = "Christian Plessl"
  p.email          = "christian@plesslweb.ch"
  p.ignore_pattern = ["tmp/*", "test/*", "test/*/*", "assets/*", "out*"]
#  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
