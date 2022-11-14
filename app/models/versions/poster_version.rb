class Versions::PosterVersion < Version
  Actions = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(:upload, :delete)

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
      when Actions[:upload] then delete_poster
      when Actions[:delete] then upload_poster
    end
  end

  def sweep_deleted **_args
    raise NotImplementedError
  end

private

  def upload_poster
    ApplicationRecord.transition do
      item.update! is_approved: true
    end
  end

  def delete_poster
    raise NotImplementedError
  end
end
