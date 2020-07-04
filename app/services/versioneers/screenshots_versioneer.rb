class Versioneers::ScreenshotsVersioneer
  pattr_initialize :item

  KEY = Versions::ScreenshotsVersion::KEY
  DEFAULT_POSITION = 99_999

  UPLOAD = Versions::ScreenshotsVersion::Actions[:upload]
  REPOSITION = Versions::ScreenshotsVersion::Actions[:reposition]
  DELETE = Versions::ScreenshotsVersion::Actions[:delete]

  APPEND_TIMEOUT = 10.minutes

  def upload image, author
    art = build_art image

    if art.save
      version = find_version(author, UPLOAD) || build_version(author, UPLOAD)
      version.item_diff[field_key] << art.id
      version.save

      version.apply_changes if version.auto_accepted?
    end

    [art, version]
  end

  def delete art_id, author
    version = find_version(author, DELETE) || build_version(author, DELETE)
    version.item_diff[field_key] << art_id
    version.save

    version.apply_changes if version.auto_accepted?

    version
  end

  def reposition ordered_ids, author
    version = build_version author, REPOSITION
    version.item_diff[field_key] = [
      item.screenshots.pluck(:id),
      ordered_ids.map(&:to_i)
    ]
    version.save

    version.apply_changes if version.auto_accepted?

    version
  end

private

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
      .where(user: author, item: item, state: %i[pending auto_accepted])
      .where('(item_diff->>:field) = :action', field: :action, action: action)
      .where('item_diff ? :field', field: field_key)
      .where('created_at > ?', APPEND_TIMEOUT.ago)
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
      state: 'pending'
    )
  end

  def field_key
    self.class::KEY
  end
end
