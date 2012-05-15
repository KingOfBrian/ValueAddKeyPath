# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "frank-valueaddkeypath"
  s.version     = .3
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Brian King"]
  s.email       = ["brianaking@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/frank-valueaddkeypath"
  s.summary     = %q{Alternative lookups for Frank}
  s.description = %q{Alternative lookups for Frank}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency( "frank-cucumber" )
  s.add_dependency( "rspec", [">=2.0"] )
  s.add_dependency( "i18n" )
  s.add_dependency( "plist" )
end
