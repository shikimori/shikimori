class Neko::Rule < Dry::Struct
  constructor_type :strict

  attribute :neko_id, Types::Achievement::NekoId
  attribute :level, Types::Coercible::Int
  attribute :image, Types::String
  attribute :border, Types::String.optional
  attribute :title_ru, Types::String
  attribute :text_ru, Types::String

  def title
    send "title_#{I18n.locale}"
  end

  def text
    send "text_#{I18n.locale}"
  end
end
