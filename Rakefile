require 'rubygems'
require 'rake'

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }

require 'jeweler'
Jeweler::Tasks.new do |gemspec|
  gemspec.name         = "wkpdf"
  gemspec.executable   = ['wkpdf']
  gemspec.summary      = "Render HTML to PDF using WebKit"
  gemspec.description  = "wkpdf renders HTML to PDF using WebKit on Mac OS X. wkpdf is "
  gemspec.description  += "implemented in RubyCocoa."
  gemspec.license      = "MIT"
  gemspec.platform     = "universal-darwin"
  gemspec.requirements << "Mac OS X 10.5 or later"
  gemspec.requirements << "RubyCocoa"
  gemspec.email        = "wkpdf@plesslweb.ch"
  gemspec.homepage     = "http://plessl.github.com/wkpdf"
  gemspec.authors      = ["Christian Plessl"]
  gemspec.add_runtime_dependency "trollop", ">= 1.16.2"
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  #  gem.add_runtime_dependency 'jabber4r', '> 0.1'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

