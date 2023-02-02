class ImageChecker
  static_facade :valid?, :image_path

  GRAY_COLOR = 128

  def valid?
    return false unless File.exist? @image_path

    if jpeg?
      jpeg_check
    else
      image_magick_check
    end
  end

private

  def jpeg?
    `identify #{@image_path}`.match? ' JPEG '
  end

  # djpeg возвращает ошибку "Premature end of JPEG file"
  # для части не до конца загруженных картинок и first_check достаточно,
  # но для части картинок, обрезанных "удачно" эта проверка не работает,
  # и djpeg на них не падает, поэтому делаем вторую проверку, проверяя содержимое на сломанные пиксели
  def jpeg_check
    Tempfile.create('jpg') do |file|
      !!(first_jpg_check(file.path) && second_jpg_check(file.read))
    end
  end

  # к сожалению битые jpg не определяет
  def image_magick_check
    ImageProcessing::MiniMagick.valid_image? File.open(@image_path)
  end

  def first_jpg_check file_path
    system "djpeg -fast -grayscale -onepass #{@image_path} > #{file_path}"
  end

  def second_jpg_check image_content
    !image_content
      .bytes[-[image_content.bytes.size, (Uploaders::PosterUploader::MAIN_WIDTH * 4)].min..]
      .all?(GRAY_COLOR)
  end

  # def second_check
  #   image = Magick::Image.read(@path).first
  #   !image.export_pixels(0, image.rows - 1, 1).all?(32_896)
  # end
end
