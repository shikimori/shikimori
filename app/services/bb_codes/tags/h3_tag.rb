class BbCodes::Tags::H3Tag
  include Singleton

  REGEXP = %r{
    \[h3\]
      (.*?)
    \[/h3\]
    \n?
  }mix

  def format text
    text.gsub REGEXP, '<h3>\1</h3>'
  end
end
