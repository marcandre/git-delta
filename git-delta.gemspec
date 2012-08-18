# -*- encoding: utf-8 -*-
require File.expand_path('../lib/git-delta/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Marc-Andre Lafortune"]
  gem.email         = ["github@marc-andre.ca"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "git-delta"
  gem.require_paths = ["lib"]
  gem.version       = Git::Delta::VERSION
end
