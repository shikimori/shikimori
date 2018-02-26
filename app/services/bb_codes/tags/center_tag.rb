class BbCodes::Tags::CenterTag
  include Singleton

  def format text
    text.gsub(
      %r{\[center\] (.*?) \[/center\]}mix,
      '<center>\1</center>'
    )
  end
end
