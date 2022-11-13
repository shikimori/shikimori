class BbCodes::Tags::WallImageTag
  include Singleton
  REGEXP = %r{
    \[ wall_image=(?<id>\d+) \]
  }mix

  def format text
    text.gsub REGEXP do |matched|
      user_image = UserImage.find_by id: $LAST_MATCH_INFO[:id]
      user_image ? html_for(user_image) : matched
    end
  end

private

  def html_for user_image
    <<~HTML.squish
      <a href="#{ImageUrlGenerator.instance.cdn_image_url user_image, :original}"
      class="b-image unprocessed"><img
      src="#{ImageUrlGenerator.instance.cdn_image_url user_image, :preview}"/></a>
    HTML
  end
end
