class CosplayGalleriesQuery < QueryObjectBase
  pattr_initialize :entry

private
  def query
    CosplayGallery
      .where(id: cosplay_gallery_ids)
      .includes(:images, :cosplayers, :characters)
      .order(created_at: :desc)
  end

  def cosplay_gallery_ids
    character_ids = entry.characters.map(&:id)
    entry_id = entry.id

    CosplayGalleryLink
      .where("(linked_id in (?) and linked_type = ?) or (linked_id = ? and linked_type = ?)",
              character_ids, Character.name, entry_id, entry.class.name)
      .select('cosplay_gallery_id')
  end
end
