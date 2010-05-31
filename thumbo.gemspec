# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{thumbo}
  s.version = "0.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Lin Jen-Shin (aka godfat 真常)"]
  s.date = %q{2010-05-31}
  s.description = %q{ create thumbnails via RMagick}
  s.email = %q{godfat (XD) godfat.org}
  s.extra_rdoc_files = ["CHANGES", "LICENSE", "NOTICE", "README.rdoc", "Rakefile", "TODO", "test/ruby.png", "thumbo.gemspec"]
  s.files = ["CHANGES", "LICENSE", "NOTICE", "README.rdoc", "Rakefile", "TODO", "lib/thumbo.rb", "lib/thumbo/exceptions/file_not_found.rb", "lib/thumbo/proxy.rb", "lib/thumbo/storages/abstract.rb", "lib/thumbo/storages/filesystem.rb", "lib/thumbo/storages/mogilefs.rb", "lib/thumbo/version.rb", "test/helper.rb", "test/ruby.png", "test/test_storage.rb", "test/test_thumbo.rb", "thumbo.gemspec"]
  s.homepage = %q{http://github.com/godfat/thumbo}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{thumbo}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{create thumbnails via RMagick}
  s.test_files = ["test/test_storage.rb", "test/test_thumbo.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rmagick>, [">= 2.6.0"])
      s.add_development_dependency(%q<bones>, [">= 3.4.3"])
    else
      s.add_dependency(%q<rmagick>, [">= 2.6.0"])
      s.add_dependency(%q<bones>, [">= 3.4.3"])
    end
  else
    s.add_dependency(%q<rmagick>, [">= 2.6.0"])
    s.add_dependency(%q<bones>, [">= 3.4.3"])
  end
end
