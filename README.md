# Description

  The active record extension implements the archive functionality to cassandra database. After record get deleted it replicates the copy of all attributes of that object to cassandra.

# Example of usage

Before you start using library you need to create column family where archived records will be stored

    create column family DeletedRecords with column_type='Super' and comparator='UTF8Type' and subcomparator='UTF8Type';

initialize cassandra connection

    ::CASSANDRA_CLIENT = Cassandra.new(keyspace, hosts)

and include module into model you want to archive after destroying

    class Service < ActiveRecord::Base
      include CassandraArchive
    end

After you delete a record, it will be automatically replicated to cassandra in the following format

    column_family will be 'DeletedRecords'
    row_id will be the same as table name, for example above it will be 'services'
    column_name is the removal timestamp, it looks like '1361974054666398'
    column_attributes will contain the active record attributes

The model will be extended with :archived method

    Service.archived                      # returns list of all archived records for that model
    Service.archived(:after => 3.day.ago) # returns list of archived records for last 3 days

    Service.archived do |timestamp, attributes|
      # the block is called for each archived record
      # timestamp shows when record has been archived
    end

## Running tests

Before you run tests do this in cassandra-cli:

    use CassandraArchive_test; # create it first if it doesn't exist
    create column family DeletedRecords with column_type='Super' and comparator='UTF8Type' and subcomparator='UTF8Type';

then run rake