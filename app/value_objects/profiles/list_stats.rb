class Profiles::ListStats
  include ShallowAttributes

  attribute :id, Integer
  attribute :name, String
  attribute :size, Integer
  attribute :grouped_id, String
  attribute :type, String

  def localized_name
    UserRate.status_name(name, type).capitalize
  end

  def any?
    size.positive?
  end
end
