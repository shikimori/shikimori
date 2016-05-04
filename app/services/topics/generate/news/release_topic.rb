# frozen_string_literal: true

class Topics::Generate::News::ReleaseTopic < Topics::Generate::News::BaseTopic
  NEW_RELEASE_DURATION = 2.weeks

private

  def is_processed
    model.released_on.present? && old_release?
  end

  def action
    AnimeHistoryAction::Released
  end

  def value
    nil
  end

  def created_at
    is_processed ? model.released_on : Time.zone.now
  end

  def old_release?
    model.released_on < NEW_RELEASE_DURATION.ago
  end
end
