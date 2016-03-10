class Versioneers::PostersVersioneer
  pattr_initialize :item

  def postmoderate image, author=nil, reason=nil
    Versions::PosterVersion.transaction do
      version = create_version author, reason
      item.update! image: image if version.persisted? && version.auto_accept!
      version
    end
  end

private

  def create_version user, reason
    Versions::PosterVersion.create(
      item: item,
      user: user,
      item_diff: { image: [] },
      reason: reason
    )
  end
end
