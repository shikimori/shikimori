class BbCodes::HrTag
  include Singleton

  def format text
    text.gsub(/\[hr\]/mi, '<hr />')
  end
end
