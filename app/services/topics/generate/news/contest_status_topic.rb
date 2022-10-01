class Topics::Generate::News::ContestStatusTopic < Topics::Generate::News::BaseTopic
  method_object %i[model! user! action!]

  def topic_klass
    Topics::NewsTopics::ContestStatusTopic
  end

  def value
    nil
  end

  def created_at
    Time.zone.now
  end

  def updated_at
    Time.zone.now
  end
end
