class HentaiAnimeImporter < FindAnimeImporter
  SERVICE = 'hentaianime'

  def find_match entry
    anime = super
    anime if anime && anime.adult?
  end
end
