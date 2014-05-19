class UserRateDecorator < BaseDecorator
  def self.scores_options
    @scores ||= 1.upto(10).map do |score|
      ["(#{score}) #{I18n.t("activerecord.attributes.user_rate.scores.#{score}")}", score]
    end
  end

  def status_line
    "<p class='status'>#{status_name.capitalize}</p>".html_safe
  end

  def score_name
    I18n.t("activerecord.attributes.user_rate.scores.#{score}")
  end

  def score_line
    if score && score > 0
      "<p class='score'>#{score_name}<span>#{score}<span></p>".html_safe
    else
      "<p class='score empty'>оценки нет</p>".html_safe
    end
  end
end
