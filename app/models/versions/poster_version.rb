class Versions::PosterVersion < Version
  Actions = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(:upload, :delete)

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
      when Actions[:upload] then delete_poster && restore_prev_poster
      when Actions[:delete] then upload_poster
    end
  end

  def sweep_deleted **_args
    poster.destroy if action == Actions[:upload]
  end

private

  # no need to wrap in transaction because it is already wrapped in transaction in version.rb
  def upload_poster
    prev_poster = associated.poster

    if prev_poster
      item_diff['prev_poster_id'] = prev_poster.id
      save!
      prev_poster.update! deleted_at: Time.zone.now
    end

    poster.update! is_approved: true
  end

  def delete_poster
    poster.update! deleted_at: Time.zone.now
  end

  def restore_prev_poster
    return unless item_diff['prev_poster_id']

    Poster.find_by(id: item_diff['prev_poster_id'])&.update! deleted_at: nil
  end
end
