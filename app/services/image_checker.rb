class ImageChecker
  def initialize path
    @path = path
  end

  def valid?
    first_check && second_check
  end

  def self.valid? path
    new(path).valid?
  end

private
  def first_check
    system "djpeg -fast -grayscale -onepass #{@path} > /dev/null"
  end

  def second_check
    image = Magick::Image.read(@path).first
    !image.export_pixels(0, image.rows-1, 1).all? {|v| v == 32896 }
  end
end
