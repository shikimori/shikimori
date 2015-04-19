class BbCodes::PTag
  include Singleton

  def format text
    text.gsub(
      /\[p\] (.*?) \[\/p\]/mix,
      '<div class="prgrph">\1</div>')
  end
end
