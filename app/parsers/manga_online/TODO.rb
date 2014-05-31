manga = Manga.find_by(name: 'Berserk')
page = manga.read_manga_id.sub 'rm_', ''
parser = ReadMangaParser.new
entry = parser.fetch_entry page

chapters = MangaOnline::ReadMangaChaptersParser.new(manga.id, entry[:read_first_url], true).chapters
db_chapters = MangaOnline::ReadMangaChaptersImporter.new(chapters).save

pages = MangaOnline::ReadMangaPagesParser.new(MangaChapter.first, true).pages
db_pages = MangaOnline::ReadMangaPagesImporter.new(pages).save
