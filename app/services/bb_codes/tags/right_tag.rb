class BbCodes::Tags::RightTag
  include Singleton

  REGEXP = %r{
    \[right\] \n?
      (.*?)
    \n? \[/right\] \n?
  }mix

  def format text
    text.gsub REGEXP, '<div class="right-text">\1</div>'
  end
end
