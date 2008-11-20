
require 'thumbo/storages/abstract'
require 'mogilefs'

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
    end

    def write filename, blob
      client.store_content(filename, klass, blob)
    end

    def delete filename
      client.delete(filename)
    end

    def file_paths filename
      client.get_paths(filename)
    end

    def client
      @client ||=
        MogileFS::MogileFS.new( :domain  => domain,
                                :hosts   => hosts,
                                :timeout => timeout_time )
    end
  end
end
