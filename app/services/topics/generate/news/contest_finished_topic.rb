module Topics::Generate::News
  class ContestFinishedTopic < ContestStartedTopic
    def topic_klass
      Topics::NewsTopics::ContestFinishedTopic
    end
  end
end
