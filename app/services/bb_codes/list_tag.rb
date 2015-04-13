class BbCodes::ListTag
  include Singleton

  def format text
    text.gsub(/\[list\] (?<ul> [\s\S]*?) \[\/list\] /mix) do
      "<ul>#{$~[:ul]}</ul>".gsub(/\[\*?\] (?<li> [^(\[|\<)]+) /mix) do |match|
        "<li>#{$~[:li]}</li>"
      end
    end
  end
end
