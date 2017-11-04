# frozen_string_literal: true

class Topics::Generate::News::EpisodeTopic < Topics::Generate::News::BaseTopic
  attr_reader :aired_at

  def initialize model:, user:, locale:, aired_at:, episode:
    super model, user, locale
    @aired_at = aired_at
    @episode = episode
  end

private

  def action
    Types::Topic::NewsTopic::Action[AnimeHistoryAction::Episode]
  end

  def value
    @episode
  end

  def created_at
    aired_at
  end
end
