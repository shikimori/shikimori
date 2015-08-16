class Versions::VideoVersion < Version
  ACTIONS = {
    upload: 'upload',
    delete: 'delete'
  }
  KEY = 'videos'

  def action
    item_diff['action']
  end

  def video
    @video ||= Video.find item_diff[KEY].first
  end

  def apply_changes
    case action
      when ACTIONS[:upload]
        upload_video

      when ACTIONS[:delete]
        delete_video

      else raise ArgumentError, "unknown action: #{action}"
    end
  end

  def rollback_changes
    raise NotImplementedError
  end

  def cleanup
    video.destroy if action == ACTIONS[:upload]
  end

private

  def upload_video
    video.confirm
  end

  def delete_video
    video.del
  end
end
