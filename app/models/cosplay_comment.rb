class CosplayComment < AniMangaComment
  IMAGES_IN_PREVIEW = 7

  def title
    gallery_linked = linked.animes.first || linked.mangas.first || linked.characters.first
    "Косплей #{gallery_linked.name}"
  end

  def preview_wall
    "[wall]#{images_bb_codes}[/wall]"
  end

private
  def images_bb_codes
    linked.images.limit(IMAGES_IN_PREVIEW).each.map do |image|
      "[url=#{ImageUrlGenerator.instance.url image, :original}][img]#{ImageUrlGenerator.instance.url image, :preview}[/img][/url]"
    end.join('')
  end
end
