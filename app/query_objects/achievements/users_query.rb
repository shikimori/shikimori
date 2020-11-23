class Achievements::UsersQuery < QueryObjectBase
  def self.fetch user
    scope = User.where.not(id: User.excluded_from_statistics)

    if user&.excluded_from_statistics?
      scope = scope.or(User.where(id: user.id))
    end

    new scope.order(:id)
  end

  def filter neko_id:, level:
    chain @scope.where(
      id: Achievement.where(neko_id: neko_id, level: level).select(:user_id)
    )
  end
end
