class Versioneers::PostersVersioneer < Versioneers::FieldsVersioneer
  pattr_initialize :item

  def premoderate image, author = nil, reason = nil
    Versions::PosterVersion.transaction do
      version = create_version image, author, reason
      @item.update! image: image if version.persisted?
      version
    end
  end

  def postmoderate image, author = nil, reason = nil
    Versions::PosterVersion.transaction do
      version = create_version image, author, reason
      @item.update! image: image if version.persisted? && version.auto_accept!
      version
    end
  end

private

  def version_klass _
    Versions::PosterVersion
  end

  def changes image
    {
      image: [@item.image_file_name, image.original_filename]
    }
  end
end
