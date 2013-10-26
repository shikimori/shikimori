class AniMangaPresenter::CosplayPresenter < BasePresenter
  def characters
    @characters ||= CosplayQuery.new.characters entry
  end

  def galleries
    @galleries ||= if (anime? || manga?) && links.any?
      CosplayQuery.new.fetch links
    else
      entry.cosplay_galleries
    end
  end

  def gallery
    @gallery ||= if params[:gallery] =~ /\d+/
      CosplaySession.find params[:gallery].to_i
    else
      galleries.first
    end
  end

  def js_data
    @js_data ||= galleries.each_with_object({}) do |gallery, memo|
      url = cosplay_url entry, gallery
      memo[url] = {
        title: gallery.full_title(entry),
        html: render_to_string(partial: 'images/image', collection: gallery.images, locals: { group_name: 'cosplay', style: :original }, formats: :html),
        edit: edit_cosplay_cosplay_gallery_url(gallery.cosplayers.first, gallery)
      }
    end
  end

  def links
    @links ||= if params[:character] == 'all'
      all_links
    elsif params[:character] == 'other'
      links_wo_characters
    elsif params[:character] == '&'
      raise NotFound.new 'ampersand'
    else
      links_by_character
    end
  end

  def all_links
    character_ids = entry.characters.map(&:id)
    entry_id = entry.id

    gallery_links = CosplayGalleryLink.where {
        (linked_id.in(character_ids) & linked_type.eq(Character.name)) |
        (linked_id.eq(entry_id) & linked_type.eq(Entry.name))
      }
  end

  def links_by_character
    character_id = Character.find(params[:character].to_i).id

    gallery_links = CosplayGalleryLink
        .where(linked_id: character_id)
        .where(linked_type: Character.name)
  end

  def links_wo_characters
    character_ids = entry.characters.map(&:id)

    link_ids = CosplayGalleryLink
        .where(linked_id: character_ids)
        .where(linked_type: Character.name)
        .pluck(:cosplay_gallery_id)

    gallery_links = CosplayGalleryLink.where {
      cosplay_gallery_id.not_in(link_ids) & linked_id.eq(entry.id) & linked_type.eq(Entry.name)
    }
  end

  def cosplay_url(entry, gallery)
    if anime? || manga?
      send "cosplay_#{entry.class.name.downcase}_url", entry, gallery, character: params[:character]
    else
      cosplay_character_url entry, gallery, character: params[:character]
    end
  end

  def anime?
    entry.class == Anime
  end

  def manga?
    entry.class == Manga
  end
end
