
require 'RMagick'

module Thumbo
  class Proxy
    attr_reader :title
    def initialize owner, title
      @owner, @title = owner, title
      @image = nil # please stop warning me @image is not defined
    end

    # image processing
    def image
      @image || (self.image = read_image)
    end

    # check if image exists in memory
    def image?
      @image
    end

    def image_with_timeout time_limit = 5
      @image || (self.image = read_image_with_timeout(time_limit))
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
      self.image = Magick::ImageList.new.from_blob(blob, &block)
      self
    end

    def to_blob &block
      self.image.to_blob(&block)
    end

    # convert format to website displable image format
    def convert_format_for_website
      image.format = 'PNG' unless ['GIF', 'JPEG'].include?(image.format)
    end

    # create thumbnails in the image list (Magick::ImageList)
    def create
      return if title == :original
      release
      limit = owner.class.thumbo_common[title]

      if limit
        create_common(limit)

      else
        limit = owner.class.thumbo_square[title]
        create_square(limit)

      end

      self
    end

    def write filename = nil, &block
      storage.write(filename || self.filename, to_blob(&block))
    end

    # delegate all
    def method_missing msg, *args, &block
      raise 'fetch image first if you want to operate the image' unless @image

      if image.__respond_to__?(msg) # operate ImageList, a dirty way because of RMagick...
         [image.__send__(msg, *args, &block)]

      elsif image.first.respond_to?(msg) # operate each Image in ImageList
        image.to_a.map{ |layer| layer.__send__(msg, *args, &block) }

      else # no such method...
        super(msg, *args, &block)

      end
    end

    # storage related
    def storage
      owner.class.thumbo_storage
    end

    def paths
      storage.paths(filename)
    end

    def delete
      storage.delete(filename)
    end

    # owner delegate
    def filename
      owner.thumbo_filename self
    end

    def uri
      owner.thumbo_uri self
    end

    # attribute
    def dimension img = image.first
      [img.columns, img.rows]
    end

    def mime_type
      image.first.mime_type
    end

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

      elsif owner.respond_to?(:thumbo_default_fileext)
        owner.thumbo_default_fileext

      else
        raise "please implement #{owner.class}\#thumbo_default_fileext or Thumbo can't guess the file extension"

      end
    end

    protected
    attr_reader :owner

    def create_common limit
      # can't use map since it have different meaning to collect here
      self.image = owner.thumbos[:original].image.collect{ |layer|
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
    end

    def create_square limit
      self.image = owner.thumbos[:original].image.collect{ |layer|
        layer.crop_resized(limit, limit).enhance
      }
    end

    private
    # fetch image from storage to memory
    # raises Magick::ImageMagickError
    def read_image
      Magick::ImageList.new.from_blob(storage.read(filename))
    end

    def read_image_with_timeout time_limit = 5
      Timeout.timeout(time_limit){ fetch }
    end
  end
end
