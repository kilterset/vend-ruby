# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "vend/version"

Gem::Specification.new do |s|
  s.name        = "vend"
  s.version     = Vend::VERSION
  s.authors     = ["Trineo Ltd"]
  s.email       = ["operations@trineo.co.nz"]
  s.homepage    = "http://trineo.co.nz"
  s.summary     = 'Vend REST API Gem'
  s.description = 'Ruby Gem to interface with the Vend REST API'

  s.rubyforge_project = "vend"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "activesupport"

  s.add_development_dependency "rspec", "~> 3.0.0"
  s.add_development_dependency "pry"
  s.add_development_dependency "webmock"

  s.add_dependency 'oauth2'
end
