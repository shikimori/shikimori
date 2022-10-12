class Club::AccessPolicy
  static_facade :allowed?, :club, :current_user

  def allowed? # rubocop:disable Metrics/CyclomaticComplexity
    return false if @club.censored? && !@current_user
    return true if moderator?

    !(@club.shadowbanned? || @club.is_private) ||
      !!@current_user&.club_ids&.include?(@club.id)
  end

private

  def moderator?
    @current_user&.moderation_staff?
  end
end
