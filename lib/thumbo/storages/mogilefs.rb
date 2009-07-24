
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
      Timeout.timeout(timeout_time){
        paths(filename).each{ |path|
          begin
            return client.get_file_data(filename)
          rescue SystemCallError
            next
          end
        }
      }
    end

    def write filename, blob
      client.store_content(filename, klass, blob)
    end

    def write_file filename, file
      client.store_file(filename, klass, file)
    end

    def delete filename
      client.delete(filename)

    rescue MogileFS::Backend::UnknownKeyError
      raise_file_not_found(filename)

    end

    def paths filename
      client.get_paths(filename)

    rescue MogileFS::Backend::UnknownKeyError
      raise_file_not_found(filename)

    end

    def exist? filename
      target = paths(filename)
      target[ rand(target.size) ]

    rescue Thumbo::FileNotFound
      false
    end

    def client
      @client ||=
        MogileFS::MogileFS.new( :domain  => domain,
                                :hosts   => hosts,
                                :timeout => timeout_time )
    end
  end
end
