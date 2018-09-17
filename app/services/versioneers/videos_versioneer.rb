class Versioneers::VideosVersioneer < Versioneers::ScreenshotsVersioneer
  KEY = Versions::VideoVersion::KEY

  def reposition _ordered_ids, _author
    raise NotImplementedError
  end

private

  def build_art params
    Video.new(
      url: params[:url],
      name: params[:name],
      kind: params[:kind],
      uploader_id: params[:uploader_id],
      anime: item
    )
  end

  def find_version author, action
  end

  def build_version author, action
    Versions::VideoVersion.new(
      item: item,
      item_diff: {
        action: action,
        self.class::KEY => []
      },
      user: author,
      state: 'pending'
    )
  end
end
