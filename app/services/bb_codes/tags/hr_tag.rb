class BbCodes::Tags::HrTag
  include Singleton

  REGEXP = /\[hr\]\n?/i

  def format text
    text.gsub(REGEXP, '<hr>')
  end
end
