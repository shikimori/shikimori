class BbCodes::WallTag
  include Singleton

  def format text
    text.gsub(
      /\[wall\] ([\s\S]*?) \[\/wall\]/mix,
      '<div class="b-shiki_wall unprocessed">\1</div>')
  end
end
