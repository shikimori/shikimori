class BbCodes::Tags::SolidTag
  include Singleton

  def format text
    text.gsub(
      %r{\[solid\] (.*?) \[/solid\]}mix,
      '<div class="solid">\1</div>'
    )
  end
end
