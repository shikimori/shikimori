class Topics::Generate::News::ContestStatusTopic < Topics::Generate::News::BaseTopic
  pattr_initialize :model, :user, :action, :locale

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
