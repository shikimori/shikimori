class BbCodes::Tags::PTag
  include Singleton

  REGEXP = %r{\[p\] (.*?) \[/p\]}mix

  def format text
    text.gsub(REGEXP, '<div class="b-prgrph">\1</div>')
  end
end
