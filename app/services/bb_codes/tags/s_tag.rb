class BbCodes::Tags::STag
  include Singleton

  def format text
    text.gsub(
      /\[s\] (.*?) \[\/s\]/mix,
      '<del>\1</del>'
    )
  end
end
