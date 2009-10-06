require 'rubygems'
require 'rake'

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name         = "wkpdf"
    gemspec.summary      = "Render HTML to PDF using WebKit"
    gemspec.description  = "wkpdf renders HTML to PDF using WebKit on Mac OS X. wkpdf is "
    gemspec.description  += "implemented in RubyCocoa."
    gemspec.platform     = "universal-darwin"
    gemspec.requirements << "Mac OS X 10.5 or later"
    gemspec.requirements << "RubyCocoa"
    gemspec.email        = "wkpdf@plesslweb.ch"
    gemspec.homepage     = "http://plessl.github.com/wkpdf"
    gemspec.authors      = ["Christian Plessl"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

