class Versioneers::VideosVersioneer < Versioneers::ScreenshotsVersioneer
  def reposition ordered_ids, author
    raise NotImplementedError
  end

private

  def add_art version, art_id
    version.item_diff[KEY] = art_id
  end

  def build_art params, author
    Video.new(
      url: params[:url],
      name: params[:name],
      kind: params[:kind],
      uploader: author,
      anime: item
    )
  end

  def find_version author, action
  end
end
