class VersionDecorator < BaseDecorator
  include HTMLDiff

  def user
    object.user || User.find(User::GuestID)
  end

  def changed_fields
    item_diff.keys
  end

  def changes_tempalte field
    'versions/text_diff'
  end

  def field_diff field
    diff item_diff[field][0], item_diff[field][1]
  end
end
