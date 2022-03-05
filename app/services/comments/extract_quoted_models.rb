class Comments::ExtractQuotedModels
  REGEXP = /
    \[(quote|comment|topic|mention|user)=([^\]]+)\]
      |
    (>\?)([^\n]+) (?:\n|\Z)
  /mx
  USER_QUOTE_REGEXP = /\d+;(?<user_id>\d+);.*/
  FORUM_ENTRY_QUOTE_REGEXP = /(?:
    t(?<topic_id>\d+) |
    c?(?<comment_id>\d+)
  );\d+;.*/x

  QUOTEABLE_MODELS = [Comment, Topic, Review]

  method_object :text

  def call
    results = @text.to_s.scan(REGEXP).map do |(tag_1, data_1, tag_2, data_2)|
      extract tag_1 || tag_2, data_1 || data_2
    end

    OpenStruct.new(
      models: results.map(&:first).compact.uniq,
      users: results.map(&:second).compact.uniq
    )
  end

private

  def extract tag, data
    case tag
      when 'quote', '>?'
        extract_quote data

      when 'mention', 'user'
        extract_mention data

      else
        extract_other data, tag
    end
  end

  def extract_quote data
    user =
      if data =~ USER_QUOTE_REGEXP
        find User, :id, $LAST_MATCH_INFO[:user_id]
      else
        find User, :nickname, data
      end

    if data =~ FORUM_ENTRY_QUOTE_REGEXP
      model = find_forum_entry(
        comment_id: $LAST_MATCH_INFO[:comment_id],
        topic_id: $LAST_MATCH_INFO[:topic_id],
        review_id: $LAST_MATCH_INFO[:review_id]
      )
    end

    [model, user]
  end

  def extract_mention data
    user = find User, :id, data

    [nil, user]
  end

  def extract_other data, tag
    model = find tag.capitalize.constantize, :id, data
    return [nil, nil] unless model && QUOTEABLE_MODELS.include?(model.class.base_class)

    [model, model.user]
  end

  def find_forum_entry comment_id:, topic_id:, review_id:
    if comment_id
      find Comment, :id, comment_id

    elsif topic_id
      find Topic, :id, topic_id

    elsif review_id
      find Review, :id, review_id
    end
  end

  def find klass, field, value
    @cache ||= {}
    @cache[klass] ||= {}
    @cache[klass][field] ||= {}
    @cache[klass][field][value] ||= klass.find_by field => value
  end
end
