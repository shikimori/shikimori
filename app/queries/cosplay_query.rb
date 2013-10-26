class CosplayQuery
  def characters(entry)
    gallery_ids = gallery_ids_by_entry entry
    linked_ids = linked_ids_by_entry entry

    fetch_characters(gallery_ids, linked_ids)
        .map(&:character)
        .sort_by(&:name)
        .uniq
  end

  # получение галерей косплея по CosplayGalleryLink
  def fetch(links)
    gallery_ids = gallery_ids_by_links links

    CosplayGallery.where(id: gallery_ids)
        .includes(:images, :cosplayers, :characters)
        .order('date desc')
  end

private
  def gallery_ids_by_entry(entry)
    CosplayGalleryLink.where(linked_id: entry.id, linked_type: entry.class.name)
          .joins(:cosplay_gallery)
          .where { cosplay_galleries.deleted.eq(0) & cosplay_galleries.confirmed.eq(1) }
          .pluck(:cosplay_gallery_id)
  end

  def linked_ids_by_entry(entry)
    entry.person_roles
        .where { character_id.not_eq(0) }
        .pluck(:character_id)
  end

  def fetch_characters(gallery_ids, linked_ids)
    CosplayGalleryLink.where {
          (cosplay_gallery_id.in(gallery_ids.empty? ? -1 : gallery_ids) | linked_id.in(linked_ids)) & linked_type.eq(Character.name)
        }
        .joins(:cosplay_gallery)
        .where { cosplay_galleries.deleted.eq(0) & cosplay_galleries.confirmed.eq(1) }
        .includes(:character)
  end

  def gallery_ids_by_links(links)
    links.includes(:cosplay_gallery)
        .where { cosplay_galleries.deleted.eq(false) &cosplay_galleries.confirmed.eq(true) }
        .order('cosplay_galleries.date desc')
        .select('cosplay_galleries.id')
        .map(&:cosplay_gallery_id)
        .compact
        .uniq
  end
end
