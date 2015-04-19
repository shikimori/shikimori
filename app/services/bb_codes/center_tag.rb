class BbCodes::CenterTag
  include Singleton

  def format text
    text.gsub(
      /\[center\] (.*?) \[\/center\]/mix,
      '<center>\1</center>')
  end
end
