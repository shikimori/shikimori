class BbCodes::PTag
  include Singleton

  def format text
    text
      .gsub(/\[p\]/mi, '<div class="prgrph">')
      .gsub(/\[\/p\]/mi, '</div>')
  end
end
