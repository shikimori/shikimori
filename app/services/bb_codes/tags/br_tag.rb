class BbCodes::Tags::BrTag
  include Singleton

  def format text
    text.gsub(/\[br\]/mix, "\n")
  end
end
