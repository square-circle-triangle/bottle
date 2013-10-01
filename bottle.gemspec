# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "bottle"
  s.version     = '0.0.15'
  s.authors     = ["Nick Marfleet"]
  s.email       = ["nick@sct.com.au"]
  s.homepage    = ""
  s.summary     = %q{This gem acts as a framework for distributed task management using amqp}
  s.description = %q{This gem acts as a framework for distributed task management using amqp}

  s.rubyforge_project = "bottle"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "amqp", '~>0.9.8'
  s.add_runtime_dependency "bunny", '~>0.8.0'

  s.add_development_dependency "rspec", '~>2.6.0'
end
