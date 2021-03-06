class BbCodes::Tags::SizeTag
  include Singleton

  REGEXP = %r{
    \[size=(?<size>\d+)\]
      (?<content>.*?)
    \[/size\]
  }mix

  MAXIMUM_FONT_SIZE = 35

  def format text
    text.gsub REGEXP do
      size = [$LAST_MATCH_INFO[:size].to_i, MAXIMUM_FONT_SIZE].min

      "<span style=\"font-size: #{size}px;\">#{$LAST_MATCH_INFO[:content]}</span>"
    end
  end
end
