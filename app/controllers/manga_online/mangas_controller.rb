class MangaOnline::MangasController < ApplicationController
  layout 'manga_online'

  def index
    manga_ids = MangaChapter.select(:manga_id).distinct.map(&:manga_id)
    @mangas = Manga.where id: manga_ids
  end

  def show
    @manga = Manga.find params[:id]
    @chapters = MangaChapter.where(manga_id: params[:id]).order(:id)
  end
end
