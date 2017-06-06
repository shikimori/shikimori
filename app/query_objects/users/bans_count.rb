class Users::BansCount
  method_object :user_id

  def call
    warnings_count + bans_count
  end

private

  def warnings_count
    query.where(duration: 0).count.positive? ? 1 : 0
  end

  def bans_count
    query.where.not(duration: 0).count
  end

  def query
    user
      .bans
      .where('created_at > ?', Time.zone.now - Ban::ACTIVE_DURATION)
      .where.not(moderator_id: User::BANHAMMER_ID)
  end

  def user
    @user ||= User.find @user_id
  end
end
