class ReviewsController < AnimesController
  load_and_authorize_resource

  before_action :actualize_resource
  before_action :add_title
  before_action :add_breadcrumbs, except: [:index]

  # один обзор
  def show
    @topic = TopicDecorator.new @review.thread
  end

  # обзоры аниме или манги
  def index
    @reviews = ReviewsQuery
      .new(@resource.object, current_user, params[:id].to_i)
      .fetch.map do |review|
        TopicDecorator.new review.thread
      end
  end

  def new
    page_title 'Новый обзор'
  end

  def edit
    page_title 'Изменение обзора'
  end

  def create
    if @review.save
      redirect_to send("#{resource_klass.name.downcase}_review_path", @resource, @review), notice: 'Рецензия создана'
    else
      new
      render :new
    end
  end

  def update
    if @review.update review_params
      redirect_to send("#{resource_klass.name.downcase}_review_path", @resource, @review), notice: 'Рецензия изменена'
    else
      edit
      render :edit
    end
  end

  def destroy
    @review.destroy
    render json: { notice: 'Рецензия удалена' }
  end

private
  def review_params
    params
      .require(:review)
      .permit :user_id, :target_type, :target_id, :text,
        :storyline, :characters, :animation, :music, :overall
  end

  # url текущего обзора
  #def review_url
    #self.send("#{resource_klass.name.downcase}_review_url", @entry, @review)
  #end

  # тип класса лежит в параметрах
  def resource_klass
    @resource_klass ||= params[:type].constantize
  end

  def resource_id
    @resource_id ||= params[:anime_id] || params[:manga_id]
  end

  def add_breadcrumbs
    breadcrumb 'Рецензии', send("#{resource_klass.name.downcase}_reviews_url", @resource)

    if @review && @review.persisted? && params[:action] != 'show'
      breadcrumb "Рецензия от #{@review.user.nickname}", send("#{resource_klass.name.downcase}_reviews_url", @resource, @review)
      @back_url = send("#{resource_klass.name.downcase}_reviews_url", @resource, @review)
    else
      @back_url = send("#{resource_klass.name.downcase}_reviews_url", @resource)
    end
  end

  def add_title
    page_title 'Рецензии'
    page_title "Рецензия от #{@review.user.nickname}" if params[:action] == 'show'
  end

  def actualize_resource
    if @resource.kind_of?(Review)
      @review = @resource
      @resource = @anime || @manga
    end
  end
end
