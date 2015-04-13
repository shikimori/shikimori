class BbCodes::BTag
  include Singleton

  def format text
    text.gsub(
      /\[b\] ([\s\S]*?) \[\/b\]/mix,
      '<strong>\1</strong>')
  end
end
