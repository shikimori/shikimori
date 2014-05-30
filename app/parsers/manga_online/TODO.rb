manga = Manga.find_by(name: 'Berserk')
page = manga.read_manga_id.sub 'rm_', ''
parser = ReadMangaParser.new
entry = parser.fetch_entry page

chapters =  MangaOnline::ReadMangaChaptersParser.new(manga.id, entry[:read_first_url]).chapters
