
require 'thumbo/storages/abstract'
require 'fileutils'
require 'digest/md5'

module Thumbo
  class Filesystem < AbstractStorage
    attr_accessor :path, :prefix_size
    def initialize opts = {}
      @path = opts[:path] || 'public/images'
      @prefix_size = opts[:prefix_size] || 1
    end

    def read filename
      File.read(calculate_path(filename))
    end

    def write filename, blob
      target = calculate_path(filename)
      FileUtils.mkdir_p(target.split('/')[0..-2].join('/'))
      (File.open(target, 'w') << blob).close
    end

    def delete filename
      target = calculate_path(filename)
      File.delete(target) if File.exist?(target)
    end

    def file_paths filename
      target = calculate_path(filename)
      File.exist?(target) ? [target] : []
    end

    private
    def calculate_path filename
      File.join( path,
                 Digest::MD5.hexdigest(filename)[0, prefix_size],
                 filename )
    end
  end
end
