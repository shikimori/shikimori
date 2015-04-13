class BbCodes::UTag
  include Singleton

  def format text
    text.gsub(
      /\[u\] ([\s\S]*?) \[\/u\]/mix,
      '<span style="text-decoration: underline;">\1</span>')
  end
end
