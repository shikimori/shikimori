class AnimeOnline::VideoData < Dry::Struct
  attribute :hosting, Types::Coercible::String
  attribute :image_url, Types::Strict::String
  attribute :player_url, Types::Strict::String
end
