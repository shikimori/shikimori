class BbCodes::RepliesTag
  include Singleton

  REGEXP = /
    (?<tag>
      (?<brs> \n|<br>)*
      \[
        replies=(?<ids> [\d,]+ )
      \]
    )
  /mx
  DISPLAY_LIMIT = 100

  def format text
    text.gsub REGEXP do |matched|
      ids = $~[:ids].split(',')
      replies = ids.take(DISPLAY_LIMIT).map {|id| "[comment=#{id}][/comment]" }.join(', ')
      "<div class=\"b-replies#{' single' if ids.one?}\">#{replies}</div>"
    end
  end
end
