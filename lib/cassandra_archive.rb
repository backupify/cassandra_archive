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
    time = DateTime.current

    cassandra_timestamp = Helper.timestamp(time)
    unix_timestamp = time.to_i.to_s

    cassandra_attributes = archived_attributes.merge('archived_at' => unix_timestamp)
    ::CASSANDRA_CLIENT.insert('DeletedRecords', self.class.table_name, {cassandra_timestamp.to_s => cassandra_attributes})
  end

  def cassandra_archive_attributes
    # return active record attributes by default
    attributes.keys
  end

  def archived_attributes
    cassandra_archive_attributes.inject({}) do |hash, attribute|
      value = send(attribute).to_s
      cassandra_encoded_value = Helper.encode_for_cassandra(value)
      hash[attribute.to_s] = cassandra_encoded_value
      hash
    end
  end

  module ClassMethods
    def archived(options = {})
      if time = options.delete(:after)
        options[:start] = Helper.timestamp(time).to_s
      end

      records = ::CASSANDRA_CLIENT.get('DeletedRecords', table_name, options)

      # encode attributes to utf8
      records.each_entry do |entry|
        entry.last.keys.each do |key|
          entry.last[key].force_encoding('UTF-8')
        end
      end

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

    def self.encode_for_cassandra(str, opts = {})
      encode_opts = {
          :invalid => :replace,
          :undef => :replace,
          :replace => ''
      }.merge(opts)

      str.encode('UTF-8', encode_opts).force_encoding('ASCII-8BIT')
    end
  end

end