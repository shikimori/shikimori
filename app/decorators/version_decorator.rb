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

  def item_template
    if item.kind_of? AnimeVideo
      'versions/anime_video'

    else
      'versions/db_entry'
    end
  end

  def field_diff field
    diff old_value(field).to_s, new_value(field).to_s
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
