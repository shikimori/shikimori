class ImageChecker
  def initialize path
    @path = path
  end

  def valid?
    # djpeg возвращает ошибку "Premature end of JPEG file"
    # для части не до конца загруженных картинок и first_check достаточно,
    # но для части картинок, обрезанных "удачно" эта проверка не работает,
    # и djpeg на них не падает, поэтому делаем вторую проверку, проверяя содержимое на сломанные пиксели
    Tempfile.create('jpg') do |file|
      !!(first_check(file.path) && second_check(file.read))
    end
  end

  def self.valid? path
    new(path).valid?
  end

private

  def first_check file_path
    system "djpeg -fast -grayscale -onepass #{@path} > #{file_path}"
  end

  def second_check image_content
    image_content.ends_with?("\x80" * (Uploaders::PosterUploader::MAIN_WIDTH * 4))
  end

  # def second_check
  #   image = Magick::Image.read(@path).first
  #   !image.export_pixels(0, image.rows - 1, 1).all?(32_896)
  # end
end
