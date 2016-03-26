# frozen_string_literal: true

class Topics::Generate::UserTopic < Topics::Generate::Base
  def call
    faye_service.create! topic
  end
end
