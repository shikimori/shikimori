class BbCodes::ImageTag
  include Singleton
  REGEXP = /
    \[
      image (?:=(?<id>\d+))
      (?:
        (?: \s c(?:lass)?=(?<klass>[\w_-]+) )? |
        (?: \s (?<width>\d+)x(?<height>\d+) )? |
        (?: \s w(?:idth)?=(?<width>\d+) )? |
        (?: \s h(?:eight)?=(?<height>\d+) )?
      )*
    \]
  /x

  def format text, text_hash
    text.gsub REGEXP do
      user_image = UserImage.find $~[:id] rescue ActiveRecord::RecordNotFound
      user_image ? html_for(user_image, $~[:width].to_i, $~[:height].to_i, $~[:klass], text_hash) : text
    end
  end

private
  def html_for user_image, width, height, klass, text_hash
    if user_image.width <= 250 && user_image.height <= 250
      if klass
        "<img src=\"#{user_image.image.url :original, false}\" class=\"#{klass}\"/>"
      else
        "<img src=\"#{user_image.image.url :original, false}\"/>"
      end

    else
      sizes_html = if width > 0 && height > 0
        ratio = 1.0 * user_image.width / user_image.height
        width = [700, width, user_image.width].min
        height = (width / ratio).to_i if 1.0 * width / height != ratio
        " width=\"#{width}\" height=\"#{height}\""

      elsif width > 0
        " width=\"#{width}\""

      elsif height > 0
        " height=\"#{height.to_i}\""

      else
        nil
      end

      "<a href=\"#{user_image.image.url :original, false}\" rel=\"#{text_hash}\"><img src=\"#{user_image.image.url sizes_html ? :preview : :thumbnail, false}\" class=\"check-width#{" #{klass}" if klass}\"#{sizes_html}/></a>"
    end
  end
end
