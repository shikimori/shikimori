class AniMangaDecorator::CosplayDecorator < BaseDecorator
  instance_cache :characters, :galleries, :gallery, :js_data, :links

  def characters
    CosplayQuery.new.characters object
  end

  def galleries
    if h.params[:character] && links.any?
      CosplayQuery.new.fetch links
    else
      object.cosplay_galleries
    end
  end

  def gallery
    if h.params[:gallery] =~ /\d+/
      CosplaySession.find h.params[:gallery].to_i
    else
      galleries.first
    end
  end

  def js_data
    template = Slim::Template.new Rails.root.join('app', 'views', 'images', '_image.html.slim').to_s

    galleries.each_with_object({}) do |gallery, memo|
      html = gallery
        .images
        .map {|image| template.render OpenStruct.new(image: image, group_name: 'cosplay', style: :original) }
        .join ''
      url = h.cosplay_url object, gallery

      memo[url] = {
        title: gallery.full_title(object),
        html: html,
        edit: h.edit_cosplay_cosplay_gallery_url(gallery.cosplayers.first, gallery)
      }
    end
  end

  def links
    if h.params[:character] == 'all'
      all_links
    elsif h.params[:character] == 'other'
      links_wo_characters
    elsif h.params[:character] == '&'
      raise NotFound.new 'ampersand'
    else
      links_by_character
    end
  end

  def all_links
    character_ids = object.characters.map(&:id)
    entry_id = object.id

    gallery_links = CosplayGalleryLink
      .where("(linked_id in (?) and linked_type = ?) or (linked_id = ? and linked_type = ?)",
              character_ids, Character.name, entry_id, Entry.name)
  end

  def links_by_character
    character_id = Character.find(h.params[:character].to_i).id

    gallery_links = CosplayGalleryLink
        .where(linked_id: character_id)
        .where(linked_type: Character.name)
  end

  def links_wo_characters
    character_ids = object.characters.map(&:id)

    link_ids = CosplayGalleryLink
        .where(linked_id: character_ids)
        .where(linked_type: Character.name)
        .pluck(:cosplay_gallery_id)

    gallery_links = CosplayGalleryLink
      .where("cosplay_gallery_id not in (?) and linked_id = ? and linked_type = ?",
              link_ids, object.id, Entry.name)
  end

  def cosplay_url entry, gallery
    if anime? || manga?
      h.send "cosplay_#{entry.class.name.downcase}_url", entry, gallery, character: h.params[:character]
    else
      h.cosplay_character_url entry, gallery, character: h.params[:character]
    end
  end
end
