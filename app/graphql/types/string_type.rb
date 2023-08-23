class Types::StringType < GraphQL::Types::String
  SOMMA_SEPARATED_DESCRIPTION = <<~TEXT
    List of values separated by comma.
    Add `!` before value to apply negative filter.\n\n
  TEXT

  def self.i18n_comma_separeted_description i18n_key
    description(
      SOMMA_SEPARATED_DESCRIPTION +
        I18n.t(i18n_key, locale: :en)
          .map { |key, description| "`#{key}` - #{description}" }
          .join("\n\n")
    )
  end
end
