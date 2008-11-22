
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

  def thumbo_filename thumbo
    "#{object_id}_#{thumbo.title}.#{thumbo.fileext}"
  end

  def thumbo_uri thumbo
    paths = thumbo.paths
    paths[rand(paths.size)]
  end

  def thumbo_mime_type
    thumbos[:original].mime_type
  end

  def create_thumbos after_scale = lambda{}
    # scale thumbnails
    self.class.thumbo_common.merge(self.class.thumbo_square).each_key{ |title|
      after_scale[ thumbos[title].create ]
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
    ).inject({}){ |result, title_value|
      title = title_value.first
      result[title] = Thumbo::Proxy.new(self, title)
      result
    }
  end

end # of Thumbs
