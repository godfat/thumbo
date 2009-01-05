
require 'test/helper'
require 'digest/md5'

class Photo
  include Thumbo
  def self.thumbo_storage
    @thumbo_storage ||= Thumbo::Filesystem.new(:path => 'tmp', :prefix_size => 2)
  end

  def self.thumbo_common
    {:common => 200}
  end

  def self.thumbo_square
    {:square => 50}
  end

  def thumbo_filename thumbo
    "#{self.object_id}_#{thumbo.title}.#{thumbo.fileext}"
  end

  def thumbo_uri thumbo
    first, last = thumbo.filename.split('_')
    "http://img.godfat.org/photos/#{first}_zzz_#{last}"
  end

  def thumbo_default_fileext
    'png'
  end

end

class ThumboDefault
  include Thumbo

  def self.thumbo_common
    {:common => 200}
  end

  def self.thumbo_square
    {:square => 50}
  end

  def thumbo_default_fileext
    'png'
  end
end

class StorageTest < TestCase
  def test_uri
    p = Photo.new
    t = p.thumbos[:original]
    t.from_blob(File.open('test/ruby.png').read)

    assert_equal( "http://img.godfat.org/photos/#{p.object_id}_zzz_original.png",
                  p.thumbos[:original].uri )
  end

  def test_default
    p = ThumboDefault.new
    t = p.thumbos[:original]
    t.from_blob(File.open('test/ruby.png').read)
    t.write

    assert_equal( "public/images/thumbo/#{Digest::MD5.hexdigest(t.filename)[0,1]}" +
                  "/#{p.object_id}_original.png",
                  p.thumbos[:original].uri )
  ensure
    File.delete(t.uri)
  end

  def test_raises
    assert_raises(Thumbo::FileNotFound) do
      Photo.new.thumbos[:original].delete
    end
  end
end
