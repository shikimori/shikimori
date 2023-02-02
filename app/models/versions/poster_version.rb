class Versions::PosterVersion < Version
  Actions = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(:upload, :delete)

  ITEM_DIFF_KEY_PREV_POSTER_ID = 'prev_poster_id'
  ITEM_DIFF_KEY_WAS_DESYNCED = 'was_desynced'
  FIELD = 'poster'

  alias poster item

  def action
    Actions[item_diff['action']]
  end

  def apply_changes
    case action
      when Actions[:upload] then upload_poster
      when Actions[:delete] then delete_poster
    end
  end

  def rollback_changes
    case action
      when Actions[:upload] then delete_poster && restore_poster(prev_poster)
      when Actions[:delete] then restore_poster poster
    end
  end

  def sweep_deleted **_args
    poster.destroy if action == Actions[:upload]
  end

  def prev_poster
    return unless item_diff[ITEM_DIFF_KEY_PREV_POSTER_ID]

    Poster.find_by id: item_diff[ITEM_DIFF_KEY_PREV_POSTER_ID]
  end

private

  # no need to wrap in transaction because it is already wrapped in transaction in version.rb
  def upload_poster
    prev_poster = associated.poster

    if prev_poster
      item_diff[ITEM_DIFF_KEY_PREV_POSTER_ID] = prev_poster.id
      save!
      prev_poster.update! deleted_at: Time.zone.now
    end

    poster.update! is_approved: true

    add_desynced FIELD, associated
    associated.save!
  end

  def delete_poster
    poster&.update! deleted_at: Time.zone.now

    if associated.respond_to?(:desynced) && associated.desynced.include?(FIELD)
      item_diff[ITEM_DIFF_KEY_WAS_DESYNCED] = true
      save!
    end

    remove_desynced FIELD, associated
    associated.save!
  end

  def restore_poster poster
    if poster
      poster.update! deleted_at: nil
    else
      true
    end
  end
end
