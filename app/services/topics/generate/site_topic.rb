# frozen_string_literal: true

class Topics::Generate::SiteTopic < Topics::Generate::BaseTopic
  def call
    topic_klass.wo_timestamp do
      topic = build_topic
      topic.save!
      topic
    end
  end

private

  # TODO: забыл, зачем это надо. по-моему эту шнягу уже можно выкинуть
  def updated_at
    nil
  end
end
