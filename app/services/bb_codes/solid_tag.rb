class BbCodes::SolidTag
  include Singleton

  def format text
    text.gsub(
      /\[solid\] ([\s\S]*?) \[\/solid\]/mix,
      '<div class="solid">\1</div>')
  end
end
