class BbCodes::RightTag
  include Singleton

  def format text
    text.gsub(
      /\[right\] ([\s\S]*?) \[\/right\]/mix,
      '<div class="right-text">\1</div>')
  end
end
