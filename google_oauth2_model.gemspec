# -*- encoding: utf-8 -*-
require File.expand_path('../lib/google_oauth2_model/version', __FILE__)

Gem::Specification.new do |gem|
  gem.add_dependency 'oauth2'
  gem.add_development_dependency 'rspec', '~> 2.13'

  gem.authors       = ["David Raynes", "Jonathan Julian"]
  gem.email         = ["rayners@410labs.com", "jonathan@410labs.com"]
  gem.description   = %q{Allow a model to store google oauth2 access and refresh tokens.}
  gem.summary       = %q{Allow a model to store google oauth2 access and refresh tokens.}
  gem.homepage      = "https://github.com/410Labs/google_oauth2_model"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "google_oauth2_model"
  gem.require_paths = ["lib"]
  gem.version       = GoogleOauth2Model::VERSION
end
