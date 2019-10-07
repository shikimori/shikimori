class BbCodes::Tags::WallTag
  include Singleton

  REGEXP = %r{
    \[wall\]
      (.*?)
    \[/wall\]
  }mix

  def format text
    text.gsub(
      REGEXP,
      '<div class="b-shiki_wall to-process" data-dynamic="wall"><div class="inner">\1</div></div>'
    )
  end
end
