require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('wkpdf', '0.1.0') do |p|
  p.description    = "Render HTML to PDF using WebKit."
  p.url            = "http://github.com/plessl/wkpdf"
  p.author         = "Christian Plessl"
  p.email          = "christian@plesslweb.ch"
  p.ignore_pattern = ["tmp/*", "test/*", "test/*/*", "assets/*"]
#  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
