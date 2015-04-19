class BbCodes::H3Tag
  include Singleton

  def format text
    text.gsub(
      /\[h3\] (.*?) \[\/h3\]/mix,
      '<h3>\1</h3>')
  end
end
