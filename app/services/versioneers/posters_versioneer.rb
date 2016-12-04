class Versioneers::PostersVersioneer
  pattr_initialize :item

  def premoderate image, author=nil, reason=nil
    Versions::PosterVersion.transaction do
      version = create_version image, author, reason
      @item.update! image: image if version.persisted?
      version
    end
  end

  def postmoderate image, author=nil, reason=nil
    Versions::PosterVersion.transaction do
      version = create_version image, author, reason
      @item.update! image: image if version.persisted? && version.auto_accept!
      version
    end
  end

private

  def create_version image, user, reason
    Versions::PosterVersion.create(
      item: @item,
      user: user,
      item_diff: {
        image: [@item.image_file_name, image.original_filename]
      },
      reason: reason
    )
  end
end
