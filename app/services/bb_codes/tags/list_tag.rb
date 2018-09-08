class BbCodes::Tags::ListTag
  include Singleton

  LIST_REGEXP = %r{
    \[list\] (?: \n )?
      (?<ul> .*?)
    \[/list\]
    (?: \r\n|\r|\n|<br> )?
  }mix

  LIST_ITEM_REGEXP = %r{
    \[\*\]
    (?<li>
      (?: (?! \[\* | \[/list\] | \n\n). )+
    )
    (?<brs> \n\n )?
  }mix

  def format text
    format_list_items format_lists(text)
  end

private

  def format_lists text
    text.gsub LIST_REGEXP do
      items = $LAST_MATCH_INFO[:ul].gsub(LIST_ITEM_REGEXP) do
        "<li>#{$LAST_MATCH_INFO[:li]}</li>"
      end

      "<ul class=\"b-list\">#{items}</ul>"
    end
  end

  def format_list_items text
    text.gsub(LIST_ITEM_REGEXP) do
      "<ul class=\"b-list\"><li>#{$LAST_MATCH_INFO[:li]}</li></ul>" +
        ($LAST_MATCH_INFO[:brs] ? "\n" : '')
    end
  end
end
