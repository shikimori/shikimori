class Versioneers::ScreenshotsVersioneer
  pattr_initialize :item

  KEY = Versions::ScreenshotsVersion::KEY

  UPLOAD = Versions::ScreenshotsVersion::ACTIONS[:upload]
  REPOSITION = Versions::ScreenshotsVersion::ACTIONS[:reposition]
  DELETE = Versions::ScreenshotsVersion::ACTIONS[:delete]

  def upload image, author
    screenshot = build_screenshot image

    if screenshot.save
      version = find_version(author, UPLOAD) || build_version(author, UPLOAD)
      version.item_diff[KEY] << screenshot.id
      version.save
    end

    [screenshot, version]
  end

  def delete screenshot_id, author
    version = find_version(author, DELETE) || build_version(author, DELETE)
    version.item_diff[KEY] << screenshot_id
    version.save
    version
  end

  def reposition ordered_ids, author
    version = build_version author, REPOSITION
    version.item_diff[KEY] = [
      item.screenshots.pluck(:id),
      ordered_ids
    ]
    version.save
    version
  end

private

  def build_screenshot image
    item.screenshots.build(
      image: image,
      position: 99999,
      url: rand,
      status: Screenshot::Uploaded
    )
  end

  def find_version author, action
    Version
      .where(user: author, item: item, state: :pending)
      .where("(item_diff->>:field) = :action", field: :action, action: action)
      .first
  end

  def build_version author, action
    Versions::ScreenshotsVersion.new(
      item: item,
      item_diff: {
        action: action,
        KEY => []
      },
      user: author,
    )
  end
end
