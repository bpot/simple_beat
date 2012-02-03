# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "simple_beat/version"

Gem::Specification.new do |s|
  s.name        = "simple_beat"
  s.version     = SimpleBeat::VERSION
  s.authors     = ["Bob Potter"]
  s.email       = ["bobby.potter@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{A simple heart beat library for ruby daemons using redis }
  s.description = %q{A simple heart beat library for ruby daemons using redis }

  s.rubyforge_project = "simple_beat"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
