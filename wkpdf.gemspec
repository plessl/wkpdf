# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{wkpdf}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christian Plessl"]
  s.date = %q{2009-02-14}
  s.default_executable = %q{wkpdf}
  s.description = %q{Render HTML to PDF using WebKit.}
  s.email = %q{christian@plesslweb.ch}
  s.executables = ["wkpdf"]
  s.extra_rdoc_files = ["bin/wkpdf", "lib/commandline_parser.rb", "lib/controller.rb", "lib/wkpdf.rb", "LICENSE", "README.rdoc", "TODO.txt"]
  s.files = ["bin/wkpdf", "CONTRIBUTORS", "FAQ", "lib/commandline_parser.rb", "lib/controller.rb", "lib/wkpdf.rb", "LICENSE", "Manifest", "Rakefile", "README.rdoc", "scripts/mirror-and-convert.rb", "test.html", "TODO.txt", "wkpdf.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/plessl/wkpdf}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Wkpdf", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{wkpdf}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Render HTML to PDF using WebKit.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
