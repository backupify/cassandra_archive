# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cassandra_archive/version'

Gem::Specification.new do |gem|
  gem.name          = "cassandra_archive"
  gem.version       = CassandraArchive::VERSION
  gem.authors       = ["Alexander Litvinovsky","Jason Haruska"]
  gem.email         = ["dev@backupify.com"]
  gem.description   = "The library allows to archive destroyed record to cassandra. For that moment ActiveRecord is supported."
  gem.summary       = "Archiving and retrieving records to cassandra"
  gem.homepage      = "http://github.com/backupify/cassandra_archive"
  gem.license       = "MIT"

  gem.add_runtime_dependency("activerecord", [">= 3.0.0"])
  gem.add_runtime_dependency("cassandra", [">= 0.12.2"])

  gem.add_development_dependency('sqlite3')
  gem.add_development_dependency('shoulda')
  gem.add_development_dependency('mocha')

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
