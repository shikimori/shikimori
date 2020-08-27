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
    \[/img\]
  }x

  MAXIMUM_IMAGES = 12

  def format text
    text.gsub(REGEXP) do |match|
      content = $LAST_MATCH_INFO[:content]

      if content.scan(IMAGES_COUNTER_REGEXP).size > MAXIMUM_IMAGES
        match
      else
        "<div class='b-shiki_wall to-process' data-dynamic='wall'>" \
          "#{content}</div>"
      end
    end
  end
end
