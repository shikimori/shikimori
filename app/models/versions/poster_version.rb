class Versions::PosterVersion < Version
  FIELD = 'image'

  def apply_changes
    item.desynced << FIELD
    item.save
  end
end
