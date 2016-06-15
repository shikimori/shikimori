# frozen_string_literal: true

# NOTE: call in before_save callback
class Anime::GenerateNews < ServiceObjectBase
  pattr_initialize :anime

  delegate :aired_on, :released_on, to: :anime
  delegate :status_change, to: :anime

  NEW_RELEASE_DATE_FOR_RELEASED_ON = 2.weeks.ago.to_date
  NEW_RELEASE_DATE_FOR_AIRED_ON = 15.months.ago.to_date

  def call
    return unless anime.status_changed?

    generate_anons_topics
    generate_ongoing_topics
    generate_release_topics
  end

private

  def generate_anons_topics
    return unless anime.anons?
    return if status_changed? 'ongoing' => 'anons'

    Site::DOMAIN_LOCALES.each do |locale|
      Topics::Generate::News::AnonsTopic.call(
        anime, anime.topic_user, locale
      )
    end
  end

  def generate_ongoing_topics
    return unless anime.ongoing?
    return if status_changed? 'released' => 'ongoing'

    Site::DOMAIN_LOCALES.each do |locale|
      Topics::Generate::News::OngoingTopic.call(
        anime, anime.topic_user, locale
      )
    end
  end

  def generate_release_topics
    return unless anime.released?
    return unless new_release?

    Site::DOMAIN_LOCALES.each do |locale|
      Topics::Generate::News::ReleasedTopic.call(
        anime, anime.topic_user, locale
      )
    end
  end

  def new_release?
    return false if released_on.try :<, NEW_RELEASE_DATE_FOR_RELEASED_ON
    return true if released_on.try :>=, NEW_RELEASE_DATE_FOR_RELEASED_ON
    return true if aired_on.try :>=, NEW_RELEASE_DATE_FOR_AIRED_ON

    false
  end

  def status_changed? change
    from, to = change.keys.first, change.values.first
    status_change[0] == from && status_change[1] == to
  end
end
