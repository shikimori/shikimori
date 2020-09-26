# class VideoExtractor::RutubeExtractor < VideoExtractor::BaseExtractor
#   PARAM = VideoExtractor::PlayerUrlExtractor::PARAM
#   HTTP = VideoExtractor::PlayerUrlExtractor::HTTP
#
#   URL_REGEX = %r{
#     #{HTTP} (?: video\. )?rutube\.ru
#
#     (?:
#       ( /player\.swf | /tracks/#{PARAM}\.html | / )
#       \? (?: hash|v ) = (?<hash>#{PARAM})
#         |
#       (?: /video )? / (?<hash>#{PARAM}) /? (?:$|"|'|>)
#         |
#       (?: /embed | /video/embed | /play/embed ) / (?<hash> \w+ )
#         |
#       / embed /\?v= (?<hash> \w+ )
#     )
#   }mix
#
#   URL_TEMPLATE = 'https://rutube.ru/play/embed/%s'
#   TRACK_INFO_TEMPLATE = 'https://rutube.ru/api/play/trackinfo/%s?format=json'
#
#   def video_data_url
#     TRACK_INFO_TEMPLATE % url.match(URL_REGEX)[:hash]
#   end
#
#   def image_url
#     parsed_data['thumbnail_url']
#   end
#
#   def player_url
#     URL_TEMPLATE % parsed_data['video_url'].match(URL_REGEX)[:hash]
#   end
#
#   def hosting
#     :rutube
#   end
#
#   def parse_data text
#     JSON.parse text
#   end
# end
