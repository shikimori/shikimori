class Versioneers::PostersVersioneer < Versioneers::FieldsVersioneer
  pattr_initialize :item

  UPLOAD = Versions::PosterVersion::Actions[:upload]
  DELETE = Versions::PosterVersion::Actions[:delete]

  def premoderate poster_data_uri, author = nil, reason = nil
    if poster_data_uri.present?
      upload_version poster_data_uri, author, reason
    elsif @item.poster.present?
      delete_version author, reason
    else
      dummy_version
    end
  end

private

  def upload_version poster_data_uri, user, reason
    poster = create_poster poster_data_uri

    Versions::PosterVersion.create!(
      item: poster,
      user: user,
      reason: reason,
      state: 'pending',
      associated: @item,
      item_diff: { 'action' => UPLOAD }
    )
  end

  def delete_version user, reason
    Versions::PosterVersion.create!(
      item: @item.poster,
      user: user,
      reason: reason,
      state: 'pending',
      associated: @item,
      item_diff: { 'action' => DELETE }
    )
  end

  def dummy_version
    Versions::PosterVersion.new
  end

  def create_poster poster_data_uri
    Poster.create(
      image_data_uri: poster_data_uri,
      item_key => @item.id,
      is_approved: false
    )
  end

  def item_key
    :"#{@item.class.base_class.name.downcase}_id"
  end
end
