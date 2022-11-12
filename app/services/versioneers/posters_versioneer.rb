class Versioneers::PostersVersioneer < Versioneers::FieldsVersioneer
  pattr_initialize :item

  UPLOAD = Versions::PosterVersion::Actions[:upload]

  def premoderate poster_data_uri, author = nil, reason = nil
    poster = create_poster poster_data_uri
    create_version poster, author, reason
  end

private

  def create_poster poster_data_uri
    Poster.create(
      image_data_uri: poster_data_uri,
      item_key => @item.id,
      is_approved: false
    )
  end

  def create_version poster, user, reason
    Versions::PosterVersion.create!(
      item: poster,
      user: user,
      reason: reason,
      state: 'pending',
      associated: @item,
      item_diff: { 'action' => UPLOAD }
    )
  end

  def item_key
    :"#{@item.class.base_class.name.downcase}_id"
  end
end
