class ImageChecker
  def initialize path
    @path = path
  end

  def valid?
    # second_check отключен, т.к. удалён гем rmagic. и вообще, я не уверен, что
    # эта проверка ещё нужна
    first_check # && second_check
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
    !image.export_pixels(0, image.rows - 1, 1).all?(32_896)
  end
end
