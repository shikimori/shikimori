class ReviewsController < AnimesController
  load_and_authorize_resource
  page_title 'Рецензии'

  # один обзор
  def show
    @resource = @anime || @manga
    index
    render :index
  end

  # обзоры аниме или манги
  def index
    @reviews = ReviewsQuery
      .new(@resource.object, current_user, params[:id].to_i)
      .fetch.map do |review|
        topic = TopicDecorator.new review.thread
        #topic.topic_mode!
        topic
      end
  end

  def new
    page_title 'Новый обзор'
    @review = @resource
    @resource = @anime || @manga
  end

  def edit
    page_title 'Изменение обзора'
    @review = @resource
    @resource = @anime || @manga
  end

  def create
    if @resource.save
      redirect_to anime_review_path(@anime || @manga, @resource), notice: 'Рецензия создана'
    else
      new
      render :new
    end
  end

  def update
    if @resource.update review_params
      redirect_to anime_review_url(@anime || @manga, @resource), notice: 'Рецензия изменена'
    else
      edit
      render :edit
    end
  end

  def destroy
    @resource.destroy
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
    @resource_id = params[:anime_id]
  end
end
