class BbCodes::WallTag
  include Singleton

  def format text
    text.gsub(
      /\[wall\] (.*?) \[\/wall\]/mix,
      '<div class="b-shiki_wall unprocessed">\1</div>')
  end
end
