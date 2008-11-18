
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

    def image_with_timeout time_limit = 5
      @image || (self.image = fetch_with_timeout(time_limit))
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

    def to_blob
      self.image.to_blob
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
        new_dimension = Thumbo.calculate_dimension(limit, layer.columns, layer.rows)

        # no need to scale
        if new_dimension == dimension(layer)
          layer

        # scale to new_dimension
        else
          layer.scale(*new_dimension)

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
    def dimension img = image.first
      [img.columns, img.rows]
    end

    def mime_type
      image.first.mime_type
    end

    def filename; owner.thumbnail_filename self; end
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

    def uri_prefix; owner.thumbnail_uri_prefix(self); end
    def uri_file;   owner.thumbnail_uri_file(  self); end
    def uri_full;  "#{uri_prefix}/#{uri_file}";       end

    private
    attr_reader :owner

    # fetch image from storage to memory
    def fetch
      Magick::ImageList.new.from_blob open(uri_full).read
    rescue Magick::ImageMagickError
      nil # nil this time, so it'll refetch next time when you call image
    end

    def fetch_with_timeout time_limit = 5
      timeout(time_limit){ fetch }
    end
  end
end
