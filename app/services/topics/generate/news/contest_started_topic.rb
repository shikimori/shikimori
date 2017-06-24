class Topics::Generate::News::ContestStatusTopic < Topics::Generate::News::BaseTopic
  pattr_initialize :model, :action, :user, :locale

  def topic_klass
    Topics::NewsTopics::ContestStatusTopic
  end

  def action
    nil
  end

  def processed
    false
  end

  def value
    nil
  end
end
