class BbCodes::WallImageTag
  include Singleton
  REGEXP = %r{
    \[ wall_image=(?<id>\d+) \]
  }mix

  def format text
    text.gsub REGEXP do |matched|
      user_image = UserImage.find_by id: $~[:id]
      user_image ? html_for(user_image) : matched
    end
  end

private

  def html_for user_image
    "<a href=\"#{ImageUrlGenerator.instance.url user_image, :original}\" class=\"b-image unprocessed\">\
<img src=\"#{ImageUrlGenerator.instance.url user_image, :preview}\"/>\
</a>"
  end
end
