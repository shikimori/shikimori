class Topics::Tag
  include ShallowAttributes

  attribute :type, String, allow_nil: false
  attribute :text, String, allow_nil: false
  attribute :url, String, allow_nil: true
end
