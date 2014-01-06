class GroupDecorator < Draper::Decorator
  delegate_all

  def url
    h.club_url object
  end

  def image
    object.logo
  end
end
