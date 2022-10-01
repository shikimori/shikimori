class Club::AccessPolicy
  static_facade :allowed?, :club, :current_user

  def allowed?
    return false if @club.censored? && !@current_user

    !(@club.shadowbanned? || @club.is_private) ||
      !!@current_user&.club_ids&.include?(@club.id)
  end
end
