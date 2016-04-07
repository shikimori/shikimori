class Versioneers::ScreenshotsVersioneer
  pattr_initialize :item

  KEY = Versions::ScreenshotsVersion::KEY
  DEFAULT_POSITION = 99999

  UPLOAD = Versions::ScreenshotsVersion::ACTIONS[:upload]
  REPOSITION = Versions::ScreenshotsVersion::ACTIONS[:reposition]
  DELETE = Versions::ScreenshotsVersion::ACTIONS[:delete]

  def upload image, author
    art = build_art image

    if art.save
      version = find_version(author, UPLOAD) || build_version(author, UPLOAD)
      version.item_diff[field_key] << art.id
      version.save
    end

    [art, version]
  end

  def delete art_id, author
    version = find_version(author, DELETE) || build_version(author, DELETE)
    version.item_diff[field_key] << art_id
    version.save
    version
  end

  def reposition ordered_ids, author
    version = build_version author, REPOSITION
    version.item_diff[field_key] = [
      item.screenshots.pluck(:id),
      ordered_ids.map(&:to_i)
    ]
    version.save
    version
  end

private

  def add_art version, art_id
    version.item_diff[field_key] << art_id
  end

  def build_art image
    item.screenshots.build(
      image: image,
      position: DEFAULT_POSITION,
      url: rand,
      status: Screenshot::UPLOADED
    )
  end

  def find_version author, action
    Version
      .where(user: author, item: item, state: :pending)
      .where("(item_diff->>:field) = :action", field: :action, action: action)
      .where("item_diff ? :field", field: field_key)
      .first
  end

  def build_version author, action
    Versions::ScreenshotsVersion.new(
      item: item,
      item_diff: {
        action: action,
        field_key => []
      },
      user: author,
    )
  end

  def field_key
    self.class::KEY
  end
end
