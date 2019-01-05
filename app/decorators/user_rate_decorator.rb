class UserRateDecorator < BaseDecorator
  instance_cache :target, :target_url

  # anime page
  def self.scores_options
    @scores ||= {}
    @scores[I18n.locale] ||= 1.upto(10).map do |score|
      ["(#{score}) #{I18n.t("activerecord.attributes.user_rate.scores.#{score}")}", score]
    end
  end

  def self.statuses_options target_type
    UserRate.statuses.map do |status_name, _status_id|
      [UserRate.status_name(status_name, target_type), status_name]
    end
  end

  def status_name
    if completed? && rewatches.positive?
      "#{object.status_name} (#{rewatches + 1}x)"
    else
      object.status_name
    end
  end

  # user list page
  def target_name
    h.localized_name(target)
  end

  def target_kind
    h.t "enumerize.#{anime? ? :anime : :manga}.kind.short.#{target.kind}" if target.kind
  end

  def target_url
    if anime?
      h.anime_url target
    else
      h.manga_url target
    end
  end

  def target
    anime? ? object.anime : object.manga
  end

  def anime?
    target_type == 'Anime'
  end
end
