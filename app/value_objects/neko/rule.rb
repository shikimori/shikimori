class Neko::Rule < Dry::Struct
  constructor_type :strict

  attribute :neko_id, Types::Achievement::NekoId
  attribute :level, Types::Coercible::Int
  attribute :image, Types::String.optional
  attribute :border_color, Types::String.optional
  attribute :title_ru, Types::String.optional
  attribute :text_ru, Types::String.optional
  attribute :title_en, Types::String.optional
  attribute :text_en, Types::String.optional
  attribute :rule, Types::Hash

  NO_RULE = new(
    neko_id: Types::Achievement::NekoId[:test],
    level: 0,
    image: nil,
    border_color: nil,
    title_ru: 'Нет названия',
    text_ru: 'Нет текста',
    title_en: 'No title',
    text_en: 'No text',
    rule: {}
  )

  def title
    send("title_#{I18n.locale}") ||
      title_ru ||
      (NO_RULE.title if self != NO_RULE)
  end

  def text
    send("text_#{I18n.locale}") ||
      text_ru ||
      (NO_RULE.text if self != NO_RULE)
  end

  def hint
    I18n.t "achievements.hint.#{neko_id}",
      threshold: rule[:threshold],
      default: proc { default_hint }
  end

  def neko_name
    I18n.t "achievements.neko_name.#{neko_id}",
    default: neko_id.to_s.capitalize
  end

  def progress
    0
  end

private

  def default_hint
    I18n.t 'achievements.hint.default',
      neko_name: neko_name,
      level: level
  end
end
