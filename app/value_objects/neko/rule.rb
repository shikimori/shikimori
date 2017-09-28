class Neko::Rule < Dry::Struct
  constructor_type :schema

  attribute :neko_id, Types::Achievement::NekoId
  attribute :level, Types::Coercible::Int
  attribute :image, Types::String
  attribute :border, Types::String
  attribute :title_ru, Types::String
  attribute :text_ru, Types::String
end
