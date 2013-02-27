require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'cassandra_archive'

::CASSANDRA_CLIENT = Cassandra.new('CassandraArchive_test', %w[localhost:9160])

require 'active_record'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database  => ":memory:")
load(File.dirname(__FILE__) + "/schema.rb")

# enable coverage reports for jenkins only
if ENV['CI']
  puts "Enabling simplecov(rcov) for jenkins"
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start
end
