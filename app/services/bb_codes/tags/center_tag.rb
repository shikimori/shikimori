class BbCodes::Tags::CenterTag
  include Singleton

  REGEXP = %r{
    \[center\]
      (.*?)
    \[/center\] \n?
  }mix

  def format text
    text.gsub REGEXP, '<center>\1</center>'
  end
end
