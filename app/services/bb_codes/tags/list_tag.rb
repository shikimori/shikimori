class BbCodes::Tags::ListTag
  include Singleton

  BBCODE_LIST_REGEXP = %r{
    \[list\] \n?
      (?<ul> .*?)
    \[/list\] \n?
  }mix

  BBCODE_LIST_ITEM_REGEXP = %r{
    (?<! = )
    \[\*\]
    (?<li>
      (?: (?! \[\* | \[/list\] | \n\n). )+
    )
    (?<brs> \n\n )?
  }mix

  LIST_OPEN_TAG = "<ul class='b-list'>"
  LIST_CLOSE_TAG = '</ul>'

  def format text
    format_bb_list_items(
      format_bb_lists(text)
    )
  end

private

  def format_bb_lists text
    text.gsub BBCODE_LIST_REGEXP do
      items = $LAST_MATCH_INFO[:ul].gsub(BBCODE_LIST_ITEM_REGEXP) do
        "<li>#{$LAST_MATCH_INFO[:li]}</li>"
      end

      "#{LIST_OPEN_TAG}#{items}#{LIST_CLOSE_TAG}"
    end
  end

  def format_bb_list_items text
    text.gsub(BBCODE_LIST_ITEM_REGEXP) do
      "#{LIST_OPEN_TAG}<li>#{$LAST_MATCH_INFO[:li]}</li>#{LIST_CLOSE_TAG}" +
        ($LAST_MATCH_INFO[:brs] ? "\n" : '')
    end
  end
end
