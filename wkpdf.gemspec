# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{wkpdf}
  s.version = "0.2.0"
  s.platform = %q{darwin-*-*}

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christian Plessl"]
  s.date = %q{2009-07-22}
  s.default_executable = %q{wkpdf}
  s.description = %q{wkpdf renders HTML to PDF using WebKit on Mac OS X. wkpdf is implemented in RubyCocoa.}
  s.email = %q{christian@plesslweb.ch}
  s.executables = ["wkpdf"]
  s.extra_rdoc_files = ["bin/wkpdf", "lib/commandline_parser.rb", "lib/controller.rb", "lib/version.rb", "lib/wkpdf.rb", "LICENSE", "README.rdoc", "TODO.txt"]
  s.files = ["bin/wkpdf", "CONTRIBUTORS", "FAQ", "HOW_TO_RELEASE.txt", "lib/commandline_parser.rb", "lib/controller.rb", "lib/version.rb", "lib/wkpdf.rb", "LICENSE", "Rakefile", "README.rdoc", "scripts/mirror-and-convert.rb", "test.html", "TODO.txt", "wkpdf.gemspec", "Manifest"]
  s.homepage = %q{http://github.com/plessl/wkpdf}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Wkpdf", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{wkpdf}
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Render HTML to PDF using WebKit.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
