# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "vend/version"

Gem::Specification.new do |s|
  s.name        = "vend-ruby"
  s.version     = Vend::VERSION
  s.authors     = ["Trineo Ltd"]
  s.email       = ["greg.signal@trineo.co.nz"]
  s.homepage    = "http://trineo.co.nz"
  s.summary     = %q{Vend REST API Gem}
  s.description = %q{Ruby Gem to interface with the Vend REST API}

  s.rubyforge_project = "vend-ruby"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
end
