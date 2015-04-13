class BbCodes::ITag
  include Singleton

  def format text
    text.gsub(
      /\[i\] ([\s\S]*?) \[\/i\]/mix,
      '<em>\1</em>')
  end
end
