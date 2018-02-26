class BbCodes::Tags::ITag
  include Singleton

  def format text
    text.gsub(
      /\[i\] (.*?) \[\/i\]/mix,
      '<em>\1</em>'
    )
  end
end
