class MangaOnline::ChaptersController < ShikimoriController
  def show
    @chapter = MangaChapter.includes(:pages).find params[:id]
    @manga = @chapter.manga
    if @chapter.pages.blank?
      # TODO : no pages view
      redirect_to online_manga_show_url @chapter.manga.id
    else
      @chapters = MangaChapter.where manga_id: @chapter.manga.id
      @page = @chapter.pages.find_by(number: (params[:page].try(:to_i) || @chapter.pages.first.number))
      unless @page
        redirect_to online_manga_chapter_show_url @chapter, @chapter.pages.last.number
        return
      end

      if @page.number > @chapter.pages.first.number
        @first_page = online_manga_chapter_show_url(@chapter, @chapter.pages.first.number)
        @prev_page = online_manga_chapter_show_url(@chapter, @page.number - 1)
      end

      if @page.number < @chapter.pages.last.number
        @next_page = online_manga_chapter_show_url(@chapter, @page.number + 1)
        @last_page = online_manga_chapter_show_url(@chapter, @chapter.pages.last.number)
      end
      @total_pages = @chapter.pages.count
    end
  end
end

