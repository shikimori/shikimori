class BbCodes::Tags::HrTag
  include Singleton

  REGEXP = /
    \[hr\] (?: \r\n|\r|\n|<br> )?
  /mix

  def format text
    text.gsub(REGEXP, '<hr>')
  end
end
