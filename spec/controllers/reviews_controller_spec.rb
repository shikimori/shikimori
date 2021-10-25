describe ReviewsController do
  let(:review) { create :review, anime: anime }
  let(:anime) { create :anime }

  describe '#show' do
    context 'html' do
      subject! { get :show, params: { id: review.id } }

      it do
        expect(response).to redirect_to(
          UrlGenerator.instance.review_url(review)
        )
      end
    end

    context 'json' do
      subject! { get :show, params: { id: review.id }, format: 'json' }

      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json'
      end
    end
  end

  describe '#tooltip' do
    subject! { get :tooltip, params: { id: review.to_param } }
    it { expect(response).to have_http_status :success }
  end

  describe '#edit' do
    include_context :authenticated, :user
    subject! { get :edit, params: { id: review.id } }

    it do
      expect(response).to have_http_status :success
      expect(response.content_type).to eq 'text/html'
    end
  end
end
