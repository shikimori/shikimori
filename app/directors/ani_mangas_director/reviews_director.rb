class AniMangasDirector::ReviewsDirector < AniMangasDirector
  alias_method :base_show, :show

  def initialize(*args)
    super *args
    params[:page] = 'reviews'
  end

  def show
    noindex
    self.index
  end

  def index
    params[:subpage] = 'index'
    base_show
    append_title! 'Обзоры'
  end

  def new
    params[:subpage] = 'edit'
    base_show
    append_title! 'Новый обзор'
  end

  def edit
    params[:subpage] = 'edit'
    append_title! 'Изменение обзора'
  end

  def update
    params[:subpage] = 'edit'
  end

  def create
    params[:subpage] = 'edit'
  end

  def destroy
    params[:subpage] = 'edit'
  end

  def self.pages
    superclass.pages
  end
end
