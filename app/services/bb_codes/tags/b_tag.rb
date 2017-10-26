class BbCodes::Tags::BTag
  include Singleton

  def format text
    text.gsub(
      /\[b\] (.*?) \[\/b\]/mix,
      '<strong>\1</strong>'
    )
  end
end
