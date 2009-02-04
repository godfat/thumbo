# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{thumbo}
  s.version = "0.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Lin Jen-Shin (a.k.a. godfat \347\234\237\345\270\270)"]
  s.date = %q{2009-02-04}
  s.description = %q{create thumbnails via RMagick}
  s.email = %q{godfat (XD) godfat.org}
  s.extra_rdoc_files = ["CHANGES", "LICENSE", "NOTICE", "README", "TODO", "thumbo.gemspec"]
  s.files = ["CHANGES", "LICENSE", "NOTICE", "README", "Rakefile", "TODO", "lib/thumbo.rb", "lib/thumbo/exceptions/file_not_found.rb", "lib/thumbo/proxy.rb", "lib/thumbo/storages/abstract.rb", "lib/thumbo/storages/filesystem.rb", "lib/thumbo/storages/mogilefs.rb", "lib/thumbo/version.rb", "test/helper.rb", "test/ruby.png", "test/test_storage.rb", "test/test_thumbo.rb", "thumbo.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/godfat/thumbo}
  s.rdoc_options = ["--diagram", "--charset=utf-8", "--inline-source", "--line-numbers", "--promiscuous", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ludy}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{create thumbnails via RMagick}
  s.test_files = ["test/test_storage.rb", "test/test_thumbo.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rmagick>, [">= 2.6.0"])
      s.add_development_dependency(%q<bones>, [">= 2.4.0"])
    else
      s.add_dependency(%q<rmagick>, [">= 2.6.0"])
      s.add_dependency(%q<bones>, [">= 2.4.0"])
    end
  else
    s.add_dependency(%q<rmagick>, [">= 2.6.0"])
    s.add_dependency(%q<bones>, [">= 2.4.0"])
  end
end
