class BbCodes::Tags::HrTag
  include Singleton

  REGEXP = /\[hr\]\n?|^(?:---+|___+|\*\*\*+)(?:\n|$)/x

  def format text
    text.gsub(REGEXP, '<hr>')
  end
end
