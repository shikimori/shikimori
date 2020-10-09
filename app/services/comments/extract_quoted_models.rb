class Comments::ExtractQuotedModels
  MENTION = /(quote|comment|topic|mention)/
  REGEXP = /
    \[#{MENTION.source}=([^\]]+)\]
  /mx

  method_object :text

  def call
    results = @text.to_s.scan(REGEXP).map { |(tag, data)| extract tag, data }

    OpenStruct.new(
      comments: results.map(&:first).compact.uniq,
      users: results.map(&:second).compact.uniq
    )
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
    user =
      if data =~ /\d+;(?<user_id>\d+);.*/
        find User, :id, $LAST_MATCH_INFO[:user_id]
      else
        find User, :nickname, data
      end

    if data =~ /c(?<comment_id>\d+);\d+;.*/
      comment = find Comment, :id, $LAST_MATCH_INFO[:comment_id]
    end

    [comment, user]
  end

  def extract_mention data
    user = find User, :id, data
    [nil, user]
  end

  def extract_other data, tag
    quoteable = find tag.capitalize.constantize, :id, data
    comment = quoteable if quoteable.is_a? Comment
    user = quoteable.try(:user)

    [comment, user]
  end

  def find klass, field, value
    @cache ||= {}
    @cache[klass] ||= {}
    @cache[klass][field] ||= {}
    @cache[klass][field][value] ||= klass.find_by field => value
  end
end
