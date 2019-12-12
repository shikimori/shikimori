class Users::UserRateHistory < Users::FormattedHistory
  def user_rate
    return unless target_id && target_type

    @user_rate ||= UserRate.find_by(
      user_id: user_id,
      target_id: target_id,
      target_type: target_type
    )
  end
end
