
require 'test/helper'

class RubyLogo
  include Thumbo

  self.thumbo_storage.path = './tmp'

  def self.thumbo_common
    { :small => 240, :thumb => 110 }
  end

  def self.thumbo_square
    { :square_medium => 48, :square_small => 24 }
  end

  def self.thumbo_labels
    { :original      => 'o',   :raw          => 'z',
      :small         => 's',   :thumb        => 't',
      :square_medium => 'msq', :square_small => 'ssq' }
  end

  attr_accessor :mime_type, :log
  def initialize blob = nil
    if blob
      thumbos[:raw].from_blob(blob).write
      thumbos[:original].image = thumbos[:raw].image
      thumbos[:raw].release
      self.mime_type = thumbos[:original].mime_type
    end
    self.log = []
  end

  def create
    create_thumbos(lambda{ |thumbo|
      log << thumbo.dimension
      thumbo.write
      thumbo.release
    })
  end

  # same as thumbnail.filename
  def thumbo_filename thumbo
    "#{self.class}_#{checksum}_" +
    "#{self.class.thumbo_labels[thumbo.title]}.#{thumbo.fileext}"
  end

  def thumbo_default_fileext
    case ext = mime_type.sub(%r{^image/}, '').downcase
      when 'jpeg'; 'jpg'
      else; ext
    end
  end

  def checksum; 'abcdefg'; end
end

class TestThumbo < MiniTest::Unit::TestCase
  Dims00 = [[ 24, 24], [ 48, 48],
            [109,110], [239,240], [995,996]]
  Dims90 = Dims00.map(&:reverse)

  def test_first
    logo = RubyLogo.new File.open('test/ruby.png').read
    assert_kind_of String, logo.thumbos[:original].to_blob

    logo.create
    assert_dimension Dims00, logo.log.sort
    assert_dimension Dims00, read_dimension

    logo2 = RubyLogo.new
    logo2.mime_type = logo.mime_type

    logo2.thumbos[:original].image
    logo2.thumbos[:original].rotate! 90
    logo2.create

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
    Magick::ImageList.new.read(*Dir['tmp/**/*.png']).to_a.map{ |img|
      [img.columns, img.rows]
    }.sort
  end

  def cleanup
    Dir['tmp/*'].each{ |prefix|
      File.delete(*Dir["#{prefix}/*.png"])
      Dir.rmdir(prefix)
    }
  end
end
