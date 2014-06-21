class MangaOnline::MangasController < MangaOnlineController
  def index
    manga_ids = MangaChapter.select(:manga_id).distinct.map(&:manga_id)
    @mangas = Manga.where id: manga_ids
  end

  def show
    @manga = @entry = Manga.find(params[:id]).decorate
    @chapters = MangaChapter.where(manga_id: params[:id]).order(:id)
    params[:page] = 'info'
    direct
  end

private
  def entry_id
    params[:id]
  end
end
