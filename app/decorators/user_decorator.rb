class UserDecorator < Draper::Decorator
  delegate_all

  def self.model_name
    User.model_name
  end

  def url
    h.profile_url self
  end

  def show_contest_link?
    (can_vote_1? || can_vote_2? || can_vote_3?) && preferences.menu_contest?
  end

  def unvoted_contests
    [can_vote_1?, can_vote_2?, can_vote_3?].count {|v| v }
  end

  def show_profile?
    if h.user_signed_in? && h.current_user.id == id
      true
    elsif preferences.profile_privacy_owner? || (!h.user_signed_in? && preferences.profile_privacy_users?)
      false
    elsif preferences.profile_privacy_friends? && !mutual_friended?
      false
    else
      true
    end
  end

  def friended?
    @favored ||= h.current_user && h.current_user.friends.any? {|v| v.id == id }
  end

  def mutual_friended?
    @mutual_friended ||= friended? && friends.any? {|v| v.id == h.current_user.id }
  end

  def history
    @history ||= UserProfileHistoryDecorator.new object
  end

  def last_online
    if object.admin?
      'всегда на сайте'
    elsif DateTime.now - 5.minutes <= last_online_at
      'сейчас на сайте'
    else
      "онлайн #{h.time_ago_in_words last_online_at, nil, true} назад"
    end
  end

  def unread_messages_url
    if unread_messages > 0 || (unread_news == 0 && unread_notifications == 0)
       h.messages_url :inbox
    elsif unread_news > 0
       h.messages_url :news
    else
       h.messages_url :notifications
    end
  end

  def avatar_url size
    if avatar.exists?
      if User::CensoredIds.include?(id) && (!h.user_signed_in? || (h.user_signed_in? && !User::CensoredIds.include?(h.current_user.id)))
        "http://www.gravatar.com/avatar/%s?s=%i&d=identicon" % [Digest::MD5.hexdigest('takandar+censored@gmail.com'), size]
      else
        avatar.url "x#{size}".to_sym
      end
    else
      "http://www.gravatar.com/avatar/%s?s=%i&d=identicon" % [Digest::MD5.hexdigest(email.downcase), size]
    end
  end

private
  def years
    DateTime.now.year - birth_on.year if birth_on
  end

  def full_years
    Date.parse(DateTime.now.to_s) - years.years + 1.day > birth_on ? years : years - 1 if birth_on
  end
end
