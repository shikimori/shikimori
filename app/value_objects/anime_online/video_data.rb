class AnimeOnline::VideoData
  include ShallowAttributes

  attribute :hosting, String
  attribute :image_url, String
  attribute :player_url, String
end
