# frozen_string_literal: true

class Topics::Generate::News::AnonsTopic < Topics::Generate::News::BaseTopic
private

  def is_processed
    false
  end

  def action
    AnimeHistoryAction::Anons
  end

  def value
    nil
  end

  def created_at
    Time.zone.now
  end
end
