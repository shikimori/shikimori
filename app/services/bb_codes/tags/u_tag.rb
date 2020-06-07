class BbCodes::Tags::UTag
  include Singleton

  def format text
    text.gsub(
      %r{\[u\] (.*?) \[/u\]}mix,
      '<u>\1</u>'
    )
  end
end
