module AgeRestrictionsConcern
  extend ActiveSupport::Concern

  def censored_forbidden?
    @is_censored_forbidden ||= begin
      return false if %w[rss os].include? request.format
      return false if params[:action] == 'tooltip' && request.xhr?

      cookies[ShikimoriController::COOKIE_AGE_OVER_18] != 'true' ||
        !user_signed_in? ||
        age_below_18?
    end
  end

  def age_below_18?
    censored_full_years && censored_full_years < 18
  end

  def censored_full_years
    return unless current_user&.birth_on

    @censored_full_years ||= begin
      years = DateTime.now.year - current_user.birth_on.year
      Date.parse(DateTime.now.to_s) - years.years + 1.day > current_user.birth_on ?
        years :
        years - 1
    end
  end

  def verify_age_restricted! collection # rubocop:disable PerceivedComplexity, CyclomaticComplexity
    return collection unless collection && censored_forbidden?

    if collection.respond_to? :any?
      raise AgeRestricted if collection.count(&:censored?) > (collection.count * 0.1)

    elsif collection.respond_to? :censored?
      raise AgeRestricted if collection.censored?

    else
      raise ArgumentError
    end
  end
end
