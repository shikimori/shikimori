class UserDecorator < Draper::Decorator
  delegate_all

  def self.model_name
    User.model_name
  end

  def about_html
    BbCodeService.instance.format_comment about
  end

  def last_online
    if object.admin?
      'всегда на сайте'
    elsif DateTime.now - 5.minutes <= last_online_at
      'сейчас на сайте'
    else
      "онлайн #{time_ago_in_words last_online_at, nil, true} назад"
    end
  end

  def common_info
    info = []
    info << h.h(name)
    info << 'муж' if male?
    info << 'жен' if female?
    unless object.birth_on.blank?
      info << "#{full_years} #{Russian.p full_years, 'год', 'года', 'лет'}" if full_years > 9
    end
    info << location
    info << website

    info.select! &:present?
    info << 'Нет личных данных' if info.empty?

    info
  end

  def history
    @history ||= ProfileHistoryDecorator.new(object, clubs.any? ? 3 : 4)
  end

  def clubs
    @clubs ||= if preferences.clubs_in_profile?
      object.groups.order(:name).limit 4
    else
      []
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

private
  def years
    DateTime.now.year - birth_on.year
  end

  def full_years
    Date.parse(DateTime.now.to_s) - years.years + 1.day > birth_on ? years : years - 1
  end
end
