class BbCodes::Markdown::ParseQuoteMeta
  method_object :meta

  def call
    return nil if @meta.blank?

    split = @meta.split(';')

    if split.one?
      nickname_meta split[0]
    else
      attributes_meta split
    end
  end

private

  def nickname_meta meta
    {
      nickname: meta
    }
  end

  def attributes_meta split
    hash = {}
    id = split[0][1..].to_i

    case split[0][0]
      when 'c' then hash[:comment_id] = id
      when 'm' then hash[:message_id] = id
      when 't' then hash[:topic_id] = id
      else return nil
    end

    hash[:user_id] = split[1].to_i
    hash[:nickname] = split[2]
    hash
  end
end
