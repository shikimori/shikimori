class Topics::Tag
  include ShallowAttributes

  attribute :type, String, allow_nil: false
  attribute :text, String, allow_nil: false
end
