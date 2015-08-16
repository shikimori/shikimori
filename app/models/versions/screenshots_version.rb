class Versions::ScreenshotsVersion < Version
  ACTIONS = {
    upload: 'upload',
    reposition: 'reposition',
    delete: 'delete'
  }
  KEY = 'screenshots'

  def action
    item_diff['action']
  end

  def screenshots
    @screenshots ||= fetch_screenshots(
      action == ACTIONS[:reposition] ? item_diff[KEY][1] : item_diff[KEY]
    )
  end

  def screenshots_prior
    @screenshots_prior ||= fetch_screenshots(
      action == ACTIONS[:reposition] ? item_diff[KEY][0] : raise(NotImplementedError)
    )
  end

  def apply_changes
    case action
      when ACTIONS[:upload]
        upload_screenshots

      when ACTIONS[:reposition]
        reposition_screenshots

      when ACTIONS[:delete]
        delete_screenshots

      else raise ArgumentError, "unknown action: #{action}"
    end
  end

  def rollback_changes
    raise NotImplementedError
  end

private

  def upload_screenshots
    screenshots.each(&:mark_accepted)
  end

  def delete_screenshots
    screenshots.each(&:mark_deleted)
  end

  def reposition_screenshots
    screenshots.each do |screenshot|
      index = item_diff[KEY][1].index(screenshot.id)
      screenshot.update(
        position: index || Versioneers::ScreenshotsVersioneer::DEFAULT_POSITION
      )
    end
  end

  def fetch_screenshots ids
    Screenshot
      .includes(:anime)
      .where(id: ids)
      .sort_by {|v| ids.index v.id }
  end
end
