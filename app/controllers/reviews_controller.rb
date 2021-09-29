class ReviewsController < ShikimoriController
  def show
    og noindex: true, nofollow: true
    @resource = Review.find_by(id: params[:id]) || NoReview.new(params[:id])

    return render :missing, status: :not_found if @resource.is_a? NoReview

    review_url = UrlGenerator.instance.review_url(@resource, is_final_url: true)
    og canonical_url: review_url

    if request.xhr? || params[:action] == 'tooltip'
      render :show # have to manually call render otherwise comment display via ajax is broken
    else
      redirect_to review_url
    end
  end

  def tooltip
    show
  end
end
