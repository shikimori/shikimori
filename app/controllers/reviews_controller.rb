class ReviewsController < ShikimoriController
  before_action :authenticate_user!, only: %i[edit]

  def show # rubocop:disable AbcSize
    og noindex: true, nofollow: true
    @resource = Review.find_by(id: params[:id]) || NoReview.new(params[:id])

    return render :missing, status: (xhr_or_json? ? :ok : :not_found) if @resource.is_a? NoReview

    review_url = UrlGenerator.instance.review_url(@resource, is_canonical: true)
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

  def edit
    @resource = Review.find params[:id]
  end
end
