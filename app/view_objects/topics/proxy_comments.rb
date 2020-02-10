# используется для отображения комментариев во вьюшках, где
# требуется наличие объекта-топика, но у комментируемой сущности
# нет топиков, а есть лишь комментарии (например, в модели User)
class Topics::ProxyComments < Topics::CommentsView
  def comments_count
    model.comments.count
  end

  # число свёрнутых комментариев
  def folded_comments
    comments_count - comments_limit
  end

  def faye_channel
    channel = model.is_a?(User) ?
      FayePublisher::PROFILE_FAYE_CHANNEL :
      model.class.name.underscore

    ["#{channel}-#{model.id}"]
  end

  def comments_limit
    is_preview ? 7 : fold_limit
  end

private

  # для адреса подгрузки комментариев
  def topic_type
    model.class.name
  end

  def model
    @topic
  end
end
