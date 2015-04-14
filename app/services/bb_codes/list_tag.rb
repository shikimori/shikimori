class BbCodes::ListTag
  include Singleton

  LIST_REGEXP = /
    \[list\]
      (?<ul> [\s\S]*?)
    \[\/list\]
  /mix

  LIST_ITEM_REGEXP = /
    \[\*\] (?<li>
      (?: (?! \[\* | \[\/list\] | <br><br>). )+
    ) (?<brs><br><br>)?

  /mix

  def format text
    format_list_items format_lists(text)
  end

private
  def format_lists text
    text.gsub LIST_REGEXP do
      items = $~[:ul].gsub(LIST_ITEM_REGEXP) do |match|
        "<li>#{$~[:li]}</li>"
      end

      "<ul class=\"b-list\">#{items}</ul>"
    end
  end

  def format_list_items text
    text.gsub(LIST_ITEM_REGEXP) do |match|
      "<ul class=\"b-list\"><li>#{$~[:li]}</li></ul>#{'<br>' if $~[:brs].present?}"
    end
  end
end
