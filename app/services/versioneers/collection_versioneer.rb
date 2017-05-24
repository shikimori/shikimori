class Versioneers::CollectionVersioneer < Versioneers::FieldsVersioneer
  pattr_initialize :item, :association_name

  def version_klass _
    Versions::CollectionVersion
  end

  def changes collection
    {
      @association_name => [
        @item.send(@association_name).map { |v| v.attributes.except('id') },
        collection
      ]
    }
  end
end
