module Topics::Generate::News
  class ContestStartedTopic < BaseTopic
    def topic_klass
      Topics::NewsTopics::ContestStartedTopic
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
end
