# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "cassandra_archive"
  gem.version       = "0.0.1"
  gem.authors       = ["Alexander Litvinovsky"]
  gem.email         = ["aliaksandr_litvinouski@epam.com"]
  gem.description   = "The library allows to archive destroyed record to cassandra. For that moment ActiveRecord is supported."
  gem.summary       = "Archiving and retrieving records to cassandra"
  gem.homepage      = "http://github.com/backupify/cassandra_archive"

  gem.add_runtime_dependency("activerecord", [">= 3.0.0"])
  gem.add_runtime_dependency("cassandra", [">= 0.12.2"])

  gem.add_development_dependency('sqlite3')
  gem.add_development_dependency('shoulda')
  gem.add_development_dependency('mocha')

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
