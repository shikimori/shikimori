class UserDecorator < BaseDecorator
  delegate_all
  instance_cache :is_friended?, :mutual_friended?, :history

  def self.model_name
    User.model_name
  end

  def url
    h.profile_url self, subdomain: nil
  end

  def show_contest_link?
    (can_vote_1? || can_vote_2? || can_vote_3?) && preferences.menu_contest?
  end

  def unvoted_contests
    [can_vote_1?, can_vote_2?, can_vote_3?].count {|v| v }
  end

  # добавлен ли пользователь в друзья ткущему пользователю
  def is_friended?
    h.current_user && h.current_user.friend_links.any? {|v| v.dst_id == id }
  end

  def mutual_friended?
    is_friended? && friended?(h.current_user)
  end

  def history
    UserProfileHistoryDecorator.new object
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
       h.profile_dialogs_url object, subdomain: nil
    elsif unread_news > 0
       h.index_profile_messages_url object, messages_type: :news, subdomain: nil
    else
       h.index_profile_messages_url object, messages_type: :notifications, subdomain: nil
    end
  end

  def avatar_url size
    if avatar.exists?
      if User::CensoredAvatarIds.include?(id) && (!h.user_signed_in? || (h.user_signed_in? && !User::CensoredAvatarIds.include?(h.current_user.id)))
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
