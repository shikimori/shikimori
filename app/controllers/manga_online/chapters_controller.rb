class MangaOnline::ChaptersController < ApplicationController
  layout 'manga_online'

  def show
    @chapter = MangaChapter.includes(:pages).find params[:id]
    @page = @chapter.pages.find_by(number: (params[:page_number].try(:to_i) || @chapter.pages.first.number))
  end
end

