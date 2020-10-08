class BbCodes::Quotes::ParseMeta
  method_object :text

  def call
    return nil if @text.blank?

    split = @text.split(';')

    if split.one?
      nickname_meta split[0]
    else
      attributes_meta split
    end
  end

private

  def nickname_meta text
    {
      nickname: text
    }
  end

  def attributes_meta split
    meta = {}
    id = split[0][1..].to_i

    case split[0][0]
      when 'c' then meta[:comment_id] = id
      when 'm' then meta[:message_id] = id
      when 't' then meta[:topic_id] = id
      else return nil
    end

    meta[:user_id] = split[1].to_i
    meta[:nickname] = split[2]
    meta
  end
end
