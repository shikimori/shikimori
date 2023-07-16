class Types::Enums::OrderEnum < GraphQL::Schema::Enum
  %w[
    id id_desc ranked kind popularity name aired_on episodes status
    random ranked_random ranked_shiki
    created_at created_at_desc
  ].each do |order|
    value order, I18n.t("by.#{order}", locale: :en, default: order)
  end
end
