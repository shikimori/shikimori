class BbCodes::Tags::SolidTag
  include Singleton

  REGEXP = %r{
    \[solid\]
      (.*?)
    \[/solid\]
  }mix

  def format text
    text.gsub(REGEXP, '<div class="solid">\1</div>')
  end
end
