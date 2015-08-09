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
    diff old_value(field), new_value(field)
  end

  def new_value field
    item_diff[field.to_s][1]
  end

  def old_value field
    if pending? || rejected?
      object.current_value field
    else
      item_diff[field.to_s].first
    end
  end
end
