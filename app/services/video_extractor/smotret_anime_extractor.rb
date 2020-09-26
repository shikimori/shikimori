# class VideoExtractor::SmotretAnimeExtractor < VideoExtractor::BaseExtractor
#   URL_REGEX = VideoExtractor::PlayerUrlExtractor::SMOTRET_ANIME_REGEXP
#   IMAGE_TEMPLATE =
#     'https://smotretanime.ru/translations/thumbnail/%i.320x180.jpg'
#
#   def image_url
#     parsed_data[:image_url]
#   end
#
#   def player_url
#     parsed_data[:player_url]
#   end
#
#   def hosting
#     parsed_data[:hosting]
#   end
#
#   def parsed_data
#     id = url.match(VideoExtractor::PlayerUrlExtractor::SMOTRET_ANIME_REGEXP)[:id]
#     {
#       image_url: IMAGE_TEMPLATE % id,
#       player_url: Url.new(VideoExtractor::PlayerUrlExtractor.call(url)).with_http.to_s,
#       hosting: :smotret_anime
#     }
#   end
# end
