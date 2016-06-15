# frozen_string_literal: true

# NOTE: call in before_save callback
class Anime::TrackStatusChanges < ServiceObjectBase
  pattr_initialize :anime

  delegate :aired_on, :released_on, to: :anime
  delegate :status_change, to: :anime

  def call
    return unless anime.status_changed?

    rollback_ongoing_status
    rollback_released_status
  end

private

  def rollback_ongoing_status
    return unless status_changed? 'anons' => 'ongoing'
    return unless aired_on
    return if aired_not_in_future?

    anime.status = :anons
  end

  def rollback_released_status
    return unless status_changed? 'ongoing' => 'released'
    # when ancient anime without released_on is marked released
    return unless released_on
    return if released_in_past?

    anime.status = :ongoing
    anime.released_on = nil
  end

  def aired_not_in_future?
    aired_on <= Time.zone.today
  end

  def released_in_past?
    released_on < Time.zone.today
  end

  def status_changed? change
    # when status has already been rollbacked previously
    return false if status_change.nil?

    from, to = change.keys.first, change.values.first
    status_change[0] == from && status_change[1] == to
  end
end
