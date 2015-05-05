class ExtractQuoted
  pattr_initialize :text

  REGEXP = /\[(quote|comment|entry|mention)=([^\]]+)\](?:(?:\[quote.*?\][\s\S]*?\[\/quote\]|[\s\S])*?)\[\/(?:quote|comment|entry|mention)\]/mx

  def perform
    text.scan(REGEXP).map do |(tag,data)|
      extract_quote tag, data
    end
  end

private

  def extract_quote tag, data
    comment = nil

    if tag == 'quote'
      user = if data =~ /\d+;(?<user_id>\d+);.*/
        User.find_by id: $~[:user_id]
      else
        User.find_by nickname: data
      end

      comment = if data =~ /c(?<comment_id>\d+);\d+;.*/
        Comment.find_by id: $~[:comment_id]
      end

    elsif tag == 'mention'
      user = User.find_by id: data

    else
      quoteable = tag.capitalize.constantize.find_by(id: data)
      comment = quoteable if quoteable.kind_of? Comment
      user = quoteable.try(:user)
    end

    [comment, user]
  end
end
