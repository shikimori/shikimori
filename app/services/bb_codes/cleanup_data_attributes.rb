class BbCodes::CleanupDataAttributes
  method_object :value

  FORBIDDEN_DATA_ATTRIBUTES = %i[
    data-action
    data-remote
    data-method
  ]

  REPLACEMENT_REGEXP = /
    (?:
      #{FORBIDDEN_DATA_ATTRIBUTES.join '|'}
    )
    (?:
      =[\w_\-]+
    )?
    \s?
  /mix

  def call
    value.gsub(REPLACEMENT_REGEXP, '')
  end
end
