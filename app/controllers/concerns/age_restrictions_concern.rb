module AgeRestrictionsConcern
  extend ActiveSupport::Concern

  def censored_forbidden?
    return false if %w[rss os].include? request.format
    return false if params[:action] == 'tooltip' && request.xhr?

    cookies[ShikimoriController::COOKIE_AGE_OVER_18] != 'true' ||
      !user_signed_in? ||
      age_below_18?
  end

  def age_below_18?
    current_user.age.present? && current_user.age < 18
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
