class ReviewsController < ShikimoriController
  def show
    og noindex: true, nofollow: true
    @resource = Review.find id: params[:id]

  rescue ActiveRecord::RecordNotFound
    render :missing, status: :not_found
  end

  def tooltip
    show
  end
end
