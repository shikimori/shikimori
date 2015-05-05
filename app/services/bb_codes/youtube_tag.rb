class BbCodes::YoutubeTag
  include Singleton

  REGEXP = /\[youtube\](.*?)\?v=([\w\-]+).*?\[\/youtube\]/im

  def format text
    text.gsub(REGEXP) do
      '<object width="465" height="360">
<param name="movie" value="http://www.youtube.com/v/'+$2+'"></param>
<param name="allowFullScreen" value="true"></param>
<param name="allowscriptaccess" value="always"></param>
<embed src="http://www.youtube.com/v/'+$2+'" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="465" height="360"></embed>
</object>'
    end
  end
end
