class BbCodes::Markdown::HeadlineParser
  include Singleton

  HEADLINES_REGEXP = /
    (?: ^ | (?<=#{BLOCK_TAG_EDGE_REGEXP.source}) )
    (?<level>\#{1,5})\ (?<text>.*) (?:\n|$)
  /x

  def format text # rubocop:disable MethodLength
    text.gsub(HEADLINES_REGEXP) do |match|
      case $LAST_MATCH_INFO[:level]
      when '#'
        h2_html $LAST_MATCH_INFO[:text]

      when '##'
        h3_html $LAST_MATCH_INFO[:text]

      when '###'
        h4_html $LAST_MATCH_INFO[:text]

      when '####'
        headline_html $LAST_MATCH_INFO[:text]

      when '#####'
        midheadline_html $LAST_MATCH_INFO[:text]

      else
        match
      end
    end
  end

private

  def h2_html text
    "<h2>#{text}</h2>"
  end

  def h3_html text
    "<h3>#{text}</h3>"
  end

  def h4_html text
    "<h4>#{text}</h4>"
  end

  def headline_html text
    "<div class='headline'>#{text}</div>"
  end

  def midheadline_html text
    "<div class='midheadline'>#{text}</div>"
  end
end
