# используется для отображения комментариев во вьюшках, где
# требуется наличие объекта-топика, но у комментируемой сущности
# нет топиков, а есть лишь комментарии (например модель User)
class TopicProxyDecorator < TopicDecorator
  def linked
    object
  end

  # число свёрнутых комментариев
  def folded_comments
    if reviews_only?
      super
    else
      object.comments.count - comments_limit
    end
  end

  def faye_channel
    ["#{model.class.name.underscore}-#{model.id}"].to_json
  end

  def comments_limit
    preview? ? 7 : fold_limit
  end

private
  # для адреса подгрузки комментариев
  def topic_type
    User.name
  end
end
