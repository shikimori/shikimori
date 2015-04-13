class BbCodes::STag
  include Singleton

  def format text
    text.gsub(
      /\[s\] ([\s\S]*?) \[\/s\]/mix,
      '<del>\1</del>')
  end
end
