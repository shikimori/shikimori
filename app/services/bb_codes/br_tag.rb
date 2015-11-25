class BbCodes::BrTag
  include Singleton

  def format text
    text.gsub(/\[br\]/mix, '<br>')
  end
end
