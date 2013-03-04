require 'cassandra'
require 'active_support/concern'

module CassandraArchive
  extend ActiveSupport::Concern

  included do
    after_commit :on => :destroy do
      archive
    end
  end

  def archive
    timestamp = Helper.timestamp(DateTime.current)
    ::CASSANDRA_CLIENT.insert('DeletedRecords', self.class.table_name, {timestamp.to_s => self.attributes})
  end

  module ClassMethods
    def archived(options = {})
      if time = options.delete(:after)
        options[:start] = Helper.timestamp(time).to_s
      end

      records = ::CASSANDRA_CLIENT.get('DeletedRecords', table_name, options)

      if block_given?
        records.each {|key, value| yield key, value}
      end

      records
    end
  end

  module Helper
    def self.timestamp(time)
      (time.to_f * 1_000_000).to_i
    end
  end

end