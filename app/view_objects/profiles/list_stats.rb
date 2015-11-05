class Profiles::ListStats < ViewObjectBase
  include Virtus.model

  attribute :id, Integer
  attribute :name, String
  attribute :size, Integer
  attribute :grouped_id, Integer
  attribute :type, String

  def id
    UserRate.statuses[name]
  end

  def localized_name
    UserRate.status_name(name, type).capitalize
  end

  def url
    h.profile_user_rates_url(
      h.current_user,
      list_type: 'anime',
      mylist: grouped_id,
      type: nil,
      studio: nil,
      publisher: nil
    )
  end

  def any?
    size > 0
  end
end
