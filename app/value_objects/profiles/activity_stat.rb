class Profiles::ActivityStat
  include ShallowAttributes

  attribute :name, Array, of: Integer
  attribute :value, Integer
end
