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

  def updated_at
    nil
  end
end
