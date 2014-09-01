class ReviewsController < AnimesController
  before_filter :authenticate_user!, only: [:new, :edit, :update, :create, :destroy]

  # один обзор
  #def show
  #end

  # обзоры аниме или манги
  def index
    page_title 'Рецензии'
  end

  #def new
    #@review = Review.new params[:review]
  #end

  #def edit
    #@review = Review.find params[:id]
  #end

  #def create
    #@review = Review.new review_params.merge(user: current_user, target: @entry.object)

    #if @review.save
      #render json: {
        #notice: 'Обзор создан',
        #url: url_for([@entry.object, @review])
      #}
    #else
      #render json: @review.errors, status: :unprocessable_entity
    #end
  #end

  #def update
    #@review = Review.find params[:id]
    #raise Forbidden unless @review.can_be_edited_by?(current_user)

    #if @review.update_attributes review_params
      #render json: { notice: 'Обзор изменён', url: review_url }
    #else
      #render json: @review.errors, status: :unprocessable_entity
    #end
  #end

  #def destroy
    #@review = Review.find params[:id]
    #raise Forbidden unless @review.can_be_deleted_by?(current_user)
    #@review.destroy

    #render json: { notice: 'Обзор удален' }
  #end

private
  # url текущего обзора
  def review_url
    self.send("#{klass.name.downcase}_review_url", @entry, @review)
  end

  # тип класса лежит в параметрах
  def klass
    @klass ||= params[:type].constantize
  end

  def review_params
    params
      .require(:review)
      .permit(:text, :storyline, :characters, :animation, :music, :overall)
  end

  def resource_id
    @resource_id = params[:anime_id]
  end
end
