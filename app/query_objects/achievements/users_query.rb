class Achievements::UsersQuery < QueryObjectBase
  def call neko_id, level
    chain @scope.where(
      id: Achievement.where(neko_id: neko_id, level: level).select(:user_id)
    )
  end
end
