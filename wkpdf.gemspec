# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{wkpdf}
  s.version = "0.2.1"
  s.platform = %q{darwin-*-*}

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christian Plessl"]
  s.date = %q{2009-07-22}
  s.default_executable = %q{wkpdf}
  s.description = %q{wkpdf renders HTML to PDF using WebKit on Mac OS X. wkpdf is implemented in RubyCocoa.}
  s.email = %q{christian@plesslweb.ch}
  s.executables = ["wkpdf"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "CONTRIBUTORS",
     "FAQ",
     "HOW_TO_RELEASE.txt",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "TODO.txt",
     "VERSION.yml",
     "assets/wkpdf_logo.png",
     "assets/wkpdf_logo.psd",
     "bin/wkpdf",
     "lib/commandline_parser.rb",
     "lib/controller.rb",
     "lib/version.rb",
     "lib/wkpdf.rb",
     "scripts/mirror-and-convert.rb",
     "test.html",
     "test/IdeasForTestcases.txt",
     "test/testcases/bounding-box-test-442px.html",
     "test/testcases/bounding-box-test-942px.html",
     "test/testcases/test.html",
     "test/testcases/test_missing.html",
     "test/testcases/test_print.css",
     "test/testcases/test_screen.css",
     "wkpdf.gemspec"
  ]
  s.homepage = %q{http://plessl.github.com/wkpdf}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
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
