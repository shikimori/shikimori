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
    @gallery ||= if @view_context.params[:gallery] =~ /\d+/
      CosplaySession.find @view_context.params[:gallery].to_i
    else
      galleries.first
    end
  end

  def js_data
    @template ||= Slim::Template.new Rails.root.join('app', 'views', 'images', '_image.html.slim').to_s
    html = gallery
      .images
      .map {|image| @template.render OpenStruct.new(image: image, group_name: 'cosplay', style: :original) }
      .join ''

    @js_data ||= galleries.each_with_object({}) do |gallery, memo|
      url = @view_context.cosplay_url entry, gallery
      memo[url] = {
        title: gallery.full_title(entry),
        html: html,
        edit: @view_context.edit_cosplay_cosplay_gallery_url(gallery.cosplayers.first, gallery)
      }
    end
  end

  def links
    @links ||= if @view_context.params[:character] == 'all'
      all_links
    elsif @view_context.params[:character] == 'other'
      links_wo_characters
    elsif @view_context.params[:character] == '&'
      raise NotFound.new 'ampersand'
    else
      links_by_character
    end
  end

  def all_links
    character_ids = entry.characters.map(&:id)
    entry_id = entry.id

    gallery_links = CosplayGalleryLink
      .where("(linked_id in (?) and linked_type = ?) or (linked_id = ? and linked_type = ?)",
              character_ids, Character.name, entry_id, Entry.name)
  end

  def links_by_character
    character_id = Character.find(@view_context.params[:character].to_i).id

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

    gallery_links = CosplayGalleryLink
      .where("cosplay_gallery_id not in (?) and linked_id = ? and linked_type = ?",
              link_ids, entry.id, Entry.name)
  end

  def cosplay_url entry, gallery
    if anime? || manga?
      @view_context.send "cosplay_#{entry.class.name.downcase}_url", entry, gallery, character: @view_context.params[:character]
    else
      @view_context.cosplay_character_url entry, gallery, character: @view_context.params[:character]
    end
  end

  def anime?
    entry.class == Anime
  end

  def manga?
    entry.class == Manga
  end
end
