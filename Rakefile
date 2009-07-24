require 'rubygems'
require 'rake'

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name         = "wkpdf"
    gemspec.summary      = "Render HTML to PDF using WebKit (Requires Mac OS X 10.5.0 or later)"
    gemspec.description  = "wkpdf renders HTML to PDF using WebKit on Mac OS X. wkpdf is "
    gemspec.description  += "implemented in RubyCocoa."
    gemspec.requirements << "Mac OS X 10.5 or later"
    gemspec.requirements << "RubyCocoa"
    gemspec.email        = "wkpdf@plesslweb.ch"
    gemspec.homepage     = "http://plessl.github.com/wkpdf"
    gemspec.authors      = ["Christian Plessl"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

