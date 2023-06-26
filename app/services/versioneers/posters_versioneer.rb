class Versioneers::PostersVersioneer < Versioneers::FieldsVersioneer
  pattr_initialize :item

  UPLOAD = Versions::PosterVersion::Actions[:upload]
  DELETE = Versions::PosterVersion::Actions[:delete]

  def premoderate params, author = nil, reason = nil
    if params[:poster_data_uri].present? || params[:poster_id].present?
      upload_version(
        data_uri: params[:poster_data_uri],
        crop_data: JSON.parse(params[:poster_crop_data], symbolize_names: true),
        poster_id: params[:poster_id],
        author: author,
        reason: reason
      )
    elsif @item.poster.present?
      delete_version author, reason
    else
      dummy_version
    end
  end

private

  def upload_version data_uri:, crop_data:, poster_id:, author:, reason:
    poster = create_poster(
      data_uri: data_uri,
      crop_data: crop_data,
      poster_id: poster_id
    )

    create_version Versions::PosterVersion.new(
      item: poster,
      user: author,
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

  def create_version version
    if version.item.persisted?
      version.save
    else
      version.errors.add :base, version.item.errors.full_messages.join(', ')
    end

    version
  end

  def dummy_version
    Versions::PosterVersion.new
  end

  def create_poster data_uri:, crop_data:, poster_id:
    existing_poster = Poster.find poster_id if poster_id.present?

    Poster.create(
      item_key => @item.id,
      crop_data: crop_data,
      is_approved: false,
      **(
        data_uri.present? ?
          { image_data_uri: data_uri } :
          {
            image: existing_poster.image.download,
            mal_url: existing_poster.mal_url
          }
      )
    )
  end

  def item_key
    :"#{@item.class.base_class.name.downcase}_id"
  end
end
