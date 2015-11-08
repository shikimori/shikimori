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

  def any?
    size > 0
  end
end
