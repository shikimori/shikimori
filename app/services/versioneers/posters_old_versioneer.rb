class Versioneers::PostersOldVersioneer < Versioneers::FieldsVersioneer
  pattr_initialize :item

  def premoderate image, author = nil, reason = nil
    Versions::PosterOldVersion.transaction do
      version = create_version image, author, reason
      @item.update! image: image if version.persisted?
      version
    end
  end

  def postmoderate _image, _author = nil, _reason = nil
    super
  end

private

  def version_klass _params
    Versions::PosterOldVersion
  end

  def changes image, _version
    {
      image: [@item.image_file_name, image.original_filename]
    }
  end
end
