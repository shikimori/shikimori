class Versions::GenresVersion < Version
  KEY = 'genres'

  def collection
    @collection ||= fetch_collection item_diff[KEY][1]
  end

  def collection_prior
    @collection_prior ||= fetch_collection item_diff[KEY][0]
  end

  def apply_changes
    item.genres = collection
  end

  def rollback_changes
    raise NotImplementedError
  end

private

  def fetch_collection ids
    Genre
      .where(id: ids)
      .sort_by {|v| Array(ids).index v.id }
  end
end
