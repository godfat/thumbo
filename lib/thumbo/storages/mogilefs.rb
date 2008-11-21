
require 'thumbo/storages/abstract'
begin
  require 'mogilefs'
rescue LoadError
  raise LoadError.new("Please install gem mogilefs-client")
end

module Thumbo
  class Mogilefs < AbstractStorage
    attr_accessor :klass, :domain, :hosts, :timeout_time
    attr_accessor :client
    def initialize opts = {}
      @klass  = opts[:klass]  || 'thumbo'
      @domain = opts[:domain] || 'thumbo'
      @hosts  = opts[:hosts]  || ['127.0.0.1:6001']
      @timeout_time = opts[:timeout_time] || 2
    end

    def read filename
      client.get_file_data(filename)

    rescue MogileFS::Backend::UnknownKeyError
      raise_file_not_found(filename)

    end

    def write filename, blob
      client.store_content(filename, klass, blob)
    end

    def delete filename
      client.delete(filename)

    rescue MogileFS::Backend::UnknownKeyError
      raise_file_not_found(filename)

    end

    # raises MogileFS::Backend::UnknownKeyError
    def paths filename
      client.get_paths(filename)

    rescue MogileFS::Backend::UnknownKeyError
      raise_file_not_found(filename)

    end

    def client
      @client ||=
        MogileFS::MogileFS.new( :domain  => domain,
                                :hosts   => hosts,
                                :timeout => timeout_time )
    end
  end
end
