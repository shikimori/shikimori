# class VideoExtractor::DailymotionExtractor < VideoExtractor::OpenGraphExtractor
#   URL_REGEX = %r{
#     https?://
#       (?:
#         (?:www\.)?dailymotion.com
#         (?:/embed|/swf)?
#         /video
#         |
#         dai.ly
#       )
#       /[\wА-я_%-]+
#       #{PARAMS}
#   }xi
# 
#   def url
#     super.gsub %r{/embed|/swf}, ''
#   end
# 
#   def hosting
#     :dailymotion
#   end
# 
#   def player_url
#     return unless parsed_data.second
# 
#     Url
#       .new(parsed_data.second)
#       .without_protocol
#       .params(autoPlay: 0)
#       .to_s
#   end
# end
