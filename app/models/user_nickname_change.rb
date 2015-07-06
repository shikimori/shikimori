class UserNicknameChange < ActiveRecord::Base
  belongs_to :user

  validates :user, :value, presence: true
  validates :value, uniqueness: { scope: [:user_id] }

  MINIMUM_COMMENTS_COUNT = 10

  before_create :should_log?
  after_create :notify_friends

private

  def should_log?
    new_user_ru = I18n.t 'omniauth_service.new_user', locale: :ru
    new_user_en = I18n.t 'omniauth_service.new_user', locale: :en

    !!(user && user.persisted? && user.day_registered? &&
      user.changes['nickname'][0] !~ /^(#{new_user_ru}|#{new_user_en})\d+/
    )
  end

  def notify_friends
    user_friends.each { |friend| notify_friend friend }
  end

  def notify_friend friend
    NotificationsService.instance.nickname_change(
      user,
      friend,
      user.changes['nickname'][0],
      user.changes['nickname'][1]
    ) rescue ActiveRecord::RecordNotUnique
  end

  def user_friends
    FriendLink.where(dst_id: user.id).includes(:src).map(&:src)
  end
end
