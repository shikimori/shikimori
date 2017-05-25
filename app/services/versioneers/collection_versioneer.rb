class Versioneers::CollectionVersioneer < Versioneers::FieldsVersioneer
  pattr_initialize :item, :association_name

  def version_klass _
    Versions::CollectionVersion
  end

  def changes collection, version
    {
      @association_name => [
        version.current_value(@association_name),
        collection
      ]
    }
  end
end
