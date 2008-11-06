
require 'rubygems'
require 'minitest/unit'
MiniTest::Unit.autorun

require 'thumbo'

class RubyLogo
  include Thumbo
  thumbnails.merge! :large => 800, :medium => 500,
                    :small => 240, :thumb => 110

  thumbnails_square.merge! :square => 75, :square_large => 200,
                           :square_medium => 48, :square_small => 24

  ThumbnailsNameTable = {
    :original => 'o', :raw => 'z',
    :large => 'l', :medium => 'm', :small => 's',
    :thumb => 't', :square => 'sq', :square_large => 'lsq',
    :square_medium => 'msq', :square_small => 'ssq'
  }

  attr_accessor :mime_type, :log
  def initialize blob = nil
    if blob
      thumbnails[:raw].from_blob(blob).write
      thumbnails[:original].image = thumbnails[:raw].image
      thumbnails[:raw].release
      self.mime_type = thumbnails[:original].mime_type
    end
    self.log = []
  end

  # create_thumbnails wrapper
  def create_thumbnails
    super lambda{ |thumbnail|
      log << thumbnail.dimension
      thumbnail.write
      thumbnail.release
    }
  end

  # same as thumbnail.filename
  def thumbnail_filename thumbnail
    "#{self.class}_#{checksum}_#{ThumbnailsNameTable[thumbnail.label]}.#{thumbnail.fileext}"
  end
  def thumbnail_default_fileext
    case ext = mime_type.sub(%r{^image/}, '').downcase
      when 'jpeg'; 'jpg'
      else; ext
    end
  end
  def checksum; 'abcdefg'; end

  # you must define this for HasManyThumbnails to produce full url
  def thumbnail_uri_prefix thumbnail
    './tmp'
  end
end

class TestThumbo < MiniTest::Unit::TestCase
  Dims00 = [[ 24, 24], [ 48, 48], [ 75, 75],
            [109,110], [200,200], [239,240],
            [499,500], [799,800], [995,996]]
  Dims90 = Dims00.map(&:reverse)

  def test_first
    logo = RubyLogo.new File.open('test/ruby.png').read
    assert_kind_of String, logo.thumbnails[:original].to_blob

    logo.create_thumbnails
    assert_dimension Dims00, logo.log.sort
    assert_dimension Dims00, read_dimension

    logo2 = RubyLogo.new
    logo2.mime_type = logo.mime_type

    logo2.thumbnails[:original].image
    logo2.thumbnails[:original].rotate! 90
    logo2.create_thumbnails

    assert_dimension Dims90[0..-2], logo2.log.sort
    assert_dimension Dims90[0..-2] << Dims00[-1], read_dimension

  ensure
    cleanup
  end

  def assert_dimension should, real
    should.zip(real).each{ |s, r|
      assert_equal s, r
    }
  end
  def read_dimension
    Magick::ImageList.new.read(*Dir['tmp/*.png']).to_a.map{ |img|
      [img.columns, img.rows]
    }.sort
  end
  def cleanup
    File.delete(*Dir['tmp/*.png'])
  end
end
