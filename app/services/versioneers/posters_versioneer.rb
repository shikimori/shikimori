class Versioneers::PostersVersioneer < Versioneers::FieldsVersioneer
  pattr_initialize :item

private

  def version_klass _params
    Versions::PosterVersion
  end
end
