module CassandraArchive
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
