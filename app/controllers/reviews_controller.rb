class ReviewsController < ShikimoriController
  def show
    og noindex: true, nofollow: true
    @resource = Review.find_by(id: params[:id]) || NoReview.new(params[:id])

    if @resource.is_a? NoReview
      render :missing, status: :not_found
    elsif request.xhr? || params[:action] == 'tooltip'
      render :show # have to manually call render otherwise comment display via ajax is broken
    else
      redirect_to UrlGenerator.instance.review_url(@resource, is_final_url: true)
    end
  end

  def tooltip
    show
  end
end
