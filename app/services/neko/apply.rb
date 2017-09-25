class Neko::Apply
  method_object :user, %i[added updated removed]

  def call
  end

private

  def add user, achievement
    user.achievements.create
  end

  def update user, achievement
  end

  def remove user, achievement
  end
end
