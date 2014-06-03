class MangaOnline::ChaptersController < ApplicationController
  layout 'manga_online'

  def show
    @chapter = MangaChapter.includes(:pages).find params[:id]
    @chapters = MangaChapter.where(manga_id: @chapter.manga.id)
    @page = @chapter.pages.find_by(number: (params[:page_number].try(:to_i) || @chapter.pages.first.number))
    redirect_to online_manga_chapter_show_url @chapter, @chapter.pages.last.number unless @page
  end
end

