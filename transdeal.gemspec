
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'transdeal/version'

Gem::Specification.new do |spec|
  spec.name = 'transdeal'
  spec.version = Transdeal::VERSION
  spec.authors = ['Aleksei Matiushkin']
  spec.email = ['aleksei.matiushkin@kantox.com']

  spec.summary = 'Helper library allowing to tackle with ActiveRecord transactions partial rollback.'
  spec.description = 'This library is supposed to simplify rolling back transactions, preserving some data still stored.'
  spec.homepage = 'http://kantox.com'
  spec.license = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  raise 'RubyGems 2.0 or newer is required.' unless spec.respond_to?(:metadata)
  # spec.metadata['allowed_push_host'] = 'TODO: Set to 'http://mygemserver.com''

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'bin'
  spec.executables = spec.files.grep(%r{^bin/}, &File.method(:basename))
  spec.require_paths = %w|lib|

  spec.add_dependency 'activerecord', '~> 3'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry', '~> 0.10'
end
