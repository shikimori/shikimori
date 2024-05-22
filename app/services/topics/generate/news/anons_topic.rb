# frozen_string_literal: true

class Topics::Generate::News::AnonsTopic < Topics::Generate::News::BaseTopic
  private

  def action
    Types::Topic::NewsTopic::Action[AnimeHistoryAction::Anons]
  end

  def value
    nil
  end

  def created_at
    Time.zone.now
  end
end
