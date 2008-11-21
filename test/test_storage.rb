
require 'test/helper'

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
    "#{self.object_id}_#{thumbo.label}.#{thumbo.fileext}"
  end

  def thumbo_uri thumbo
    first, last = thumbo.filename.split('_')
    "http://img.godfat.org/photos/#{first}_zzz_#{last}"
  end

  def thumbo_default_fileext
    'png'
  end

end

class StorageTest < MiniTest::Unit::TestCase
  def test_uri
    p = Photo.new
    t = p.thumbos[:original]
    t.from_blob(File.open('test/ruby.png').read)

    assert_equal( "http://img.godfat.org/photos/#{p.object_id}_zzz_original.png",
                  p.thumbos[:original].uri )
  end

  def test_raises
    assert_raises(Thumbo::FileNotFound) do
      Photo.new.thumbos[:original].delete
    end
  end
end
