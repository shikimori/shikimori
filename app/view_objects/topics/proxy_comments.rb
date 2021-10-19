# используется для отображения комментариев во вьюшках, где
# требуется наличие объекта-топика, но у комментируемой сущности
# нет топиков, а есть лишь комментарии (например, в модели User)
class Topics::ProxyComments < Topics::CommentsView
  def faye_channel
    %W[/#{model.class.base_class.name.downcase}-#{model.id}]
  end

  def comments_limit
    is_preview ? 7 : fold_limit
  end

  def comments_count
    model.comments.count
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
