# -*- encoding: utf-8 -*-
require File.expand_path('../lib/background_job_tracking/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["nat"]
  gem.email         = ["nat.lownes@gmail.com"]
  gem.description   = %q{ActiveRecord extension to allow tracking / rescheduling Delayed Job jobs on object creation / update.}
  gem.summary       = %q{ActiveRecord extension to allow tracking / rescheduling Delayed Job jobs on object creation / update.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "background_job_tracking"
  gem.require_paths = ["lib"]
  gem.version       = BackgroundJobTracking::VERSION

  gem.add_development_dependency "rspec", "~> 2.6"
end
