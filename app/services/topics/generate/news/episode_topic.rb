# frozen_string_literal: true

class Topics::Generate::News::EpisodeTopic < Topics::Generate::News::BaseTopic
  method_object %i[model! user! aired_at! episode!]

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
