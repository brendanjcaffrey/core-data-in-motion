require File.expand_path('../lib/cdim/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['brendanjcaffrey']
  gem.email         = ['brendan at jcaffrey dot com']
  gem.description   = 'CoreData wrapper for RubyMotion'
  gem.summary       = gem.description
  gem.homepage      = 'http://github.com/brendanjcaffrey/core-data-in-motion'

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'core-data-in-motion'
  gem.require_paths = ['lib']
  gem.version       = CDIM::VERSION

  gem.add_dependency 'motion-support'
end

