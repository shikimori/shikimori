class Ability
  include CanCan::Ability

  def initialize user
    return unless user

    can(:manage, UserRate) {|v| v.user_id == user.id }
    can [:cleanup, :reset], UserRate
  end
end
