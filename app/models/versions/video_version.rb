class Versions::VideoVersion < Version
  KEY = 'videos'
  Actions = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(:upload, :delete)

  def action
    Actions[item_diff['action']]
  end

  def video
    @video ||= Video.find_by id: item_diff[KEY].first
  end

  def apply_changes
    case action
      when Actions[:upload] then upload_video
      when Actions[:delete] then delete_video
    end
  end

  def rollback_changes
    raise NotImplementedError
  end

  def cleanup
    video.destroy if Actions[action] == Actions[:upload]
  end

private

  def upload_video
    video.confirm
  end

  def delete_video
    video.del
  end
end
