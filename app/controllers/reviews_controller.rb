class ReviewsController < ShikimoriController
  def show
    og noindex: true, nofollow: true
    @resource = Review.find_by(id: params[:id]) || NoReview.new(params[:id])

    if @resource.is_a? NoReview
      render :missing, status: :not_found
    else
      render :show # have to manually call render otherwise comment display via ajax is broken
    end
  end

  def tooltip
    show
  end
end
