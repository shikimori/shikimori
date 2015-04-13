class BbCodes::CenterTag
  include Singleton

  def format text
    text.gsub(
      /\[center\] ([\s\S]*?) \[\/center\]/mix,
      '<center>\1</center>')

  end
end
