class BbCodes::Tags::SizeTag
  include Singleton

  REGEXP = %r{
    \[size=(\d+)\]
      (.*?)
    \[/size\]
  }mix

  def format text
    text.gsub REGEXP, '<span style="font-size: \1px;">\2</span>'
  end
end
