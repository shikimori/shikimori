class UserRateDecorator < BaseDecorator
  instance_cache :target, :target_url

  # anime page
  def self.scores_options
    @scores ||= 1.upto(10).map do |score|
      ["(#{score}) #{I18n.t("activerecord.attributes.user_rate.scores.#{score}")}", score]
    end
  end

  def self.statuses_options target_type
    UserRate.statuses.map do |status_name, status_id|
      [UserRate.status_name(status_name, target_type), status_id]
    end
  end

  def score_line
    if score && score > 0
      "<p class='score'>#{score_name}<span>#{score}<span></p>".html_safe
    else
      "<p class='score empty'>оценки нет</p>".html_safe
    end
  end

  # user list page
  def target_name
    h.localized_name(target)
  end

  def target_kind
    target.kind.blank? ? '' : h.localized_kind(target, true)
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
