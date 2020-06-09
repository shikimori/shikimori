class Comments::ExtractQuoted
  MENTION = /(quote|comment|topic|mention)/
  REGEXP = %r{
    \[#{MENTION.source}=([^\]]+)\]
      (?:
        (?:\[#{MENTION.source}.*?\][\s\S]*?\[/#{MENTION.source}\]|[\s\S])*?
      )
    \[/#{MENTION.source}\]
  }mx

  method_object :text

  def call
    @text
      .to_s
      .scan(REGEXP)
      .map { |(tag, data)| extract tag, data }
  end

private

  def extract tag, data
    case tag
      when 'quote'
        extract_quote data

      when 'mention'
        extract_mention data

      else
        extract_other data, tag
    end
  end

  def extract_quote data
    meta = data.split(';')

    if meta.one?
      {
        nickname: meta[0]
      }
    else
      {
        comment_id: meta[0].to_i,
        user_id: meta[1].to_i,
        nickname: meta[2],
      }
    end
  end
  #     if data =~ /\d+;(?<user_id>\d+);.*/
  #       find User, :id, $LAST_MATCH_INFO[:user_id]
  #     else
  #       find User, :nickname, data
  #     end
  # 
    # if data =~ /c(?<comment_id>\d+);\d+;.*/
  #     comment = find Comment, :id, $LAST_MATCH_INFO[:comment_id]
  #   end
  # 
  #   [comment, user]
  # end
  # 
  # def extract_mention data
  #   user = find User, :id, data
  #   [nil, user]
  # end
  # 
  # def extract_other data, tag
  #   quoteable = find tag.capitalize.constantize, :id, data
  #   comment = quoteable if quoteable.is_a? Comment
  #   user = quoteable.try(:user)
  # 
  #   [comment, user]
  # end
end
