# frozen_string_literal: true

class Topics::Generate::UserTopic < Topics::Generate::BaseTopic
  def call
    topic = build_topic
    faye_service.create! topic
    topic
  end

private

  def faye_service
    FayeService.new user, nil
  end
end
