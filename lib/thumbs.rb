
require 'thumbs/proxy'

module Thumbs
  def self.included model
    model.__send__ :extend, Thumbs::ClassMethod
  end

  module ClassMethod
    def thumbnails
      # could we avoid class variable?
      @@thumbs_thumbnails ||= {}
    end
    def thumbnails_square
      # could we avoid class variable?
      @@thumbs_thumbnails_square ||= {}
    end
  end

  def thumbnails
    @thumbnails ||= init_thumbnails
  end

  # same as thumbnail.filename, for writing
  def thumbnail_filename thumbnail
    "#{object_id}_#{thumbnail.label}.#{thumbnail.fileext}"
  end

  # same as thumbnail.fileuri, for fetching
  def thumbnail_fileuri thumbnail
    thumbnail_filename thumbnail
  end
  def thumbnail_mime_type
    thumbnails[:original].mime_type
  end
  def create_thumbnails after_scale = lambda{}
    # scale common thumbnails
    self.class.thumbnails.each_key{ |label|
      after_scale[ thumbnails[label].create ]
    }
    # scale square thumbnails
    self.class.thumbnails_square.each_key{ |label|
      after_scale[ thumbnails[label].create_square ]
    }
    # the last one don't scale at all, but call hook too
    after_scale[ thumbnails[:original] ]

    self
  end

  private
  def init_thumbnails
    self.class.const_get('ThumbnailsNameTable').inject({}){ |thumbnails, name|
      label = name.first
      thumbnails[label] = Thumbs::Proxy.new self, label
      thumbnails
    }
  end

end # of Thumbs
