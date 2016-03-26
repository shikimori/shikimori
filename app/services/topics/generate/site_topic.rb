# frozen_string_literal: true

class Topics::Generate::SiteTopic < Topics::Generate::Base
  def call
    topic_klass.wo_timestamp { topic.save! }
  end

private

  def topic_attributes
    super.update updated_at: nil
  end
end
