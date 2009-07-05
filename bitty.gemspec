# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bitty}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["oleg dashevskii"]
  s.date = %q{2009-07-05}
  s.email = %q{be9@be9.ru}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bitty.gemspec",
     "lib/bitty.rb",
     "lib/bitty/bit_proxy.rb",
     "test/bitty_test.rb",
     "test/proxy_test.rb",
     "test/support/models.rb",
     "test/support/schema.rb",
     "test/test_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/be9/bitty}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{ActiveRecord plugin for rich bitfields}
  s.test_files = [
    "test/bitty_test.rb",
     "test/proxy_test.rb",
     "test/support/models.rb",
     "test/support/schema.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
