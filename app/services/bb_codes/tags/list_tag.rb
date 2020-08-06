class BbCodes::Tags::ListTag
  include Singleton

  BBCODE_LIST_REGEXP = %r{
    \[list\] \n?
      (?<ul> .*?)
    \[/list\] \n?
  }mix

  BBCODE_LIST_ITEM_REGEXP = %r{
    \[\*\]
    (?<li>
      (?: (?! \[\* | \[/list\] | \n\n). )+
    )
    (?<brs> \n\n )?
  }mix

  def format text
    format_markdown_lists(
      format_bb_list_items(
        format_bb_lists(text)
      )
    )
  end

private

  def format_bb_lists text
    text.gsub BBCODE_LIST_REGEXP do
      items = $LAST_MATCH_INFO[:ul].gsub(BBCODE_LIST_ITEM_REGEXP) do
        "<li>#{$LAST_MATCH_INFO[:li]}</li>"
      end

      "<ul class=\"b-list\">#{items}</ul>"
    end
  end

  def format_bb_list_items text
    text.gsub(BBCODE_LIST_ITEM_REGEXP) do
      "<ul class=\"b-list\"><li>#{$LAST_MATCH_INFO[:li]}</li></ul>" +
        ($LAST_MATCH_INFO[:brs] ? "\n" : '')
    end
  end

  def format_markdown_lists text
    text
  end
end
