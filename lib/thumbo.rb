
require 'thumbo/proxy'
require 'thumbo/exceptions/file_not_found'

module Thumbo
  def self.included model
    model.extend(Thumbo::ClassMethod)
  end

  def self.calculate_dimension limit, width, height
    long, short = width >= height ? [width, height] : [height, width]

    if long <= limit # stay on
      [width, height]

    elsif width == height # square
      [limit, limit]

    else # detect which is longer

      # assume width is longer
      new_width, new_height = limit, short * (limit.to_f / long)

      # swap if height is longer
      new_width, new_height = new_height, new_width if long == height

      [new_width, new_height]
    end
  end

  module ClassMethod
    def thumbo_storage
      @thumbo_storage ||= begin
        require 'thumbo/storages/filesystem'
        Thumbo::Filesystem.new
      end
    end

    def thumbo_common
      {}
    end

    def thumbo_square
      {}
    end

    def thumbo_labels
      {}
    end
  end

  def thumbos
     @thumbos ||= init_thumbos
  end

  # same as thumbnail.filename, for writing
  def thumbo_filename thumbo
    "#{object_id}_#{thumbo.label}.#{thumbo.fileext}"
  end

  # same as thumbnail.fileuri, for fetching
  def thumbo_uri_file thumbo
    thumbo_filename thumbo
  end

  def thumbo_mime_type
    thumbos[:original].mime_type
  end

  def create_thumbos after_scale = lambda{}
    # scale thumbnails
    self.class.thumbo_common.merge(self.class.thumbo_square).each_key{ |label|
      after_scale[ thumbos[label].create ]
    }

    # the last one don't scale at all, but call hook too
    after_scale[ thumbos[:original] ]

    self
  end

  private
  def init_thumbos
    # just to make sure original is setup.
    {:original => true}.merge(
      self.class.thumbo_common.merge(
        self.class.thumbo_square.merge(
          self.class.thumbo_labels
        )
      )
    ).inject({}){ |result, label_value|
      label = label_value.first
      result[label] = Thumbo::Proxy.new(self, label)
      result
    }
  end

end # of Thumbs
