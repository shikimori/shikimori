# frozen_string_literal: true

class Topics::Generate::News::EpisodeTopic < Topics::Generate::News::BaseTopic
  attr_reader :aired_at

  def initialize model, user, locale, aired_at
    super model, user, locale
    @aired_at = aired_at
  end

private

  def is_processed
    false
  end

  def action
    AnimeHistoryAction::Episode
  end

  def value
    model.episodes_aired.to_s
  end

  def created_at
    aired_at
  end
end
