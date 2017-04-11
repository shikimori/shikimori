class Topics::EntryTopics::PersonTopic < Topics::EntryTopic
  def human_role
    if linked.producer && linked.mangaka
      'режиссёра аниме и автора манги'
    elsif linked.producer
      'режиссёра аниме'
    elsif linked.mangaka
      'автора манги'
    elsif linked.seyu
      'сэйю'
    else
      'человека'
    end
  end
end
