class BbCodes::Html5VideoTag
  include Singleton
  MAX_SHORT_URL_SIZE = 65

  REGEXP = /
    \[html5_video\]
      (?<url> .*?)
    \[\/html5_video\]
  /mix

  def format text
    text.gsub REGEXP do
      "<div class=\"b-video fixed\">
  <img class=\"to-process\" data-dynamic=\"html5_video\" \
src=\"/assets/globals/html5_video.png\" \
srcset=\"/assets/globals/html5_video@2x.png 2x\" \
data-video=\"#{$~[:url]}\" />
  <a class=\"marker\" href=\"#{$~[:url]}\">html5</a>
</div>"
    end
  end
end
