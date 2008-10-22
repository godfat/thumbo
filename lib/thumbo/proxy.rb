
require 'RMagick'
require 'open-uri'
require 'timeout'

module Thumbo
  class Proxy
    attr_reader :label
    def initialize owner, label
      @owner, @label = owner, label
    end

    # image processing
    def image
      @image || (self.image = fetch)
    end

    def image_without_timeout
      @image || (self.image = fetch_without_timeout)
    end

    def image= new_image
      release
      @image = new_image
    end

    # is this helpful or not?
    def release
      @image = nil
      GC.start
      self
    end

    # e.g.,
    # thumbnails[:original].from_blob uploaded_file.read
    def from_blob blob, &block
      self.image = Magick::ImageList.new.from_blob blob, &block
      self
    end

    # convert format to website displable image format
    def convert_format_for_website
      image.format = 'PNG' unless ['GIF', 'JPEG'].include?(image.format)
    end

    # create thumbnails in the image list (Magick::ImageList)
    def create
      return if label == :original
      limit = owner.class.thumbnails[label]

      # can't use map since it have different meaning to collect here
      self.image = owner.thumbnails[:original].image.collect{ |layer|
        # i hate column and row!! nerver remember which is width...
        width, height = layer.columns, layer.rows
        long, short = width >= height ? [width, height] : [height, width]

        if long <= limit # no need to scale
          layer
        elsif width == height # direct scale
          layer.scale limit, limit
        else # detect which is longer

          # assume width is longer
          new_width, new_height = limit, short * (limit.to_f / long)

          # swap if height is longer
          new_width, new_height = new_height, new_width if long == height

          layer.scale new_width, new_height
         end
      }

      self
    end

    # e.g.,
    # thumbnails[:square].create_square
    def create_square
      return if label == :original
      release
      limit = owner.class.thumbnails_square[label]

      self.image = owner.thumbnails[:original].image.collect{ |layer|
        layer.crop_resized(limit, limit).enhance
      }

      self
    end

    def write filename = nil
      if filename
        image.write filename
      else
        image.write self.uri_full
      end
    end

    # delegate all
    def method_missing msg, *args, &block
      raise 'fetch image first if you want to operate the image' unless @image

      if image.__respond_to__?(msg) # operate ImageList, a dirty way because of RMagick...
         [image.__send__(msg, *args, &block)]
      elsif image.first.respond_to?(msg) # operate each Image in ImageList
        image.to_a.map{ |layer| layer.__send__ msg, *args, &block }
      else # no such method...
        super msg, *args, &block
      end
    end

    # attribute
    def dimension
      [image.first.columns, image.first.rows]
    end

    def mime_type
      image.first.mime_type
    end

    def filename; owner.thumbnail_filename self; end
    def fileuri; owner.thumbnail_fileuri self; end
    def fileext
      if @image
        case ext = image.first.format
          when 'PNG8';   'png'
          when 'PNG24';  'png'
          when 'PNG32';  'png'
          when 'GIF87';  'gif'
          when 'JPEG';   'jpg'
          when 'PJPEG';  'jpg'
          when 'BMP2';   'bmp'
          when 'BMP3';   'bmp'
          when 'TIFF64'; 'tiff'
          else; ext.downcase
        end
      elsif owner.respond_to?(:thumbnail_default_fileext)
        owner.thumbnail_default_fileext
      else
        raise "please implement #{owner.class}\#thumbnail_default_fileext or ThumbnailProxy can't guess the file extension"
      end
    end

    def uri_full
      "#{owner.host_with_protocol}/#{owner.path}/#{fileuri}"
    end

    private
    attr_reader :owner

    # fetch image from storage to memory
    def fetch_without_timeout
      Magick::ImageList.new.from_blob open(uri_full).read
    rescue Magick::ImageMagickError
      nil # nil this time, so it'll refetch next time when you call image
    end
    def fetch; timeout(5){ fetch_without_timeout }; end
  end
end
