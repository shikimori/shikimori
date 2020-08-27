class BbCodes::Tags::WallTag
  include Singleton

  REGEXP = %r{
    \[wall\]
      (?<content>.*?)
    \[/wall\]
  }mix
  IMAGES_COUNTER_REGEXP = %r{
    \[poster= |
    \[image= |
    \[wall_image= |
    \[/img\] |
    <img
  }x

  MAXIMUM_IMAGES = 12

  RESTRICTION_TEXT = BbCodes::Tags::CodeTag::CODE_INLINE_OPEN_TAG +
    "[wall]%<count>s/#{MAXIMUM_IMAGES}[/wall]" +
    BbCodes::Tags::CodeTag::CODE_INLINE_CLOSE_TAG

  def format text
    text.gsub(REGEXP) do
      content = $LAST_MATCH_INFO[:content]
      images_count = content.scan(IMAGES_COUNTER_REGEXP).size

      if images_count > MAXIMUM_IMAGES
        Kernel.format RESTRICTION_TEXT, count: images_count
      else
        "<div class='b-shiki_wall to-process' data-dynamic='wall'>" \
          "#{content}</div>"
      end
    end
  end
end
