class CosplayGalleriesQuery < SimpleQueryBase
  pattr_initialize :entry

private
  def query
    CosplayGallery
      .where(confirmed: true, id: cosplay_gallery_ids(entry))
      .includes(:images, :cosplayers, :characters)
      .order(created_at: :desc)
  end

  def cosplay_gallery_ids entry
    if entry.kind_of? Character
      character_gallery_ids entry
    else
      anime_gallery_ids entry
    end
  end

  def anime_gallery_ids entry
    character_ids = entry.characters.map(&:id)
    entry_id = entry.id

    CosplayGalleryLink
      .where("(linked_id in (?) and linked_type = ?) or (linked_id = ? and linked_type = ?)",
              character_ids, Character.name, entry_id, entry.class.name)
      .select('cosplay_gallery_id')
  end

  def character_gallery_ids entry
    entry
      .cosplay_gallery_links
      .select('cosplay_gallery_id')
  end
end
