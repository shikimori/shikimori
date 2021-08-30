describe Api::V1::SummariesController do
  include_context :authenticated
  let(:user) { create :user, :day_registered, nickname: 'zxc' } # do not remove. for apipie specs there is additional Timecop.freeze
  let(:summary) { create :summary, user: user, anime: anime }
  let(:anime) { create :anime }

  describe '#create' do
    let(:params) do
      {
        anime_id: anime.id,
        body: body,
        opinion: 'positive'
      }
    end

    subject! do
      post :create,
        params: {
          frontend: is_frontend,
          summary: params
        },
        format: :json
    end

    context 'success' do
      let(:body) { 'x' * Summary::MIN_BODY_SIZE }

      context 'frontend' do
        let(:is_frontend) { true }
        it_behaves_like :successful_resource_change, :frontend
      end

      context 'api', :show_in_doc do
        let(:is_frontend) { false }
        it_behaves_like :successful_resource_change, :api
      end
    end

    context 'failure' do
      let(:body) { '' }

      context 'frontend' do
        let(:is_frontend) { true }
        it_behaves_like :failed_resource_change
      end

      context 'api' do
        let(:is_frontend) { false }
        it_behaves_like :failed_resource_change
      end
    end
  end

  describe '#update' do
    let(:params) { { body: body } }

    subject! do
      patch :update,
        params: {
          id: summary.id,
          frontend: is_frontend,
          summary: params
        },
        format: :json
    end

    context 'success' do
      let(:body) { 'b' * Summary::MIN_BODY_SIZE }

      context 'frontend' do
        let(:is_frontend) { true }
        it_behaves_like :successful_resource_change, :frontend
      end

      context 'api', :show_in_doc do
        let(:is_frontend) { false }
        it_behaves_like :successful_resource_change, :api
      end
    end

    context 'failure' do
      let(:body) { '' }

      context 'frontend' do
        let(:is_frontend) { true }
        it_behaves_like :failed_resource_change
      end

      context 'api' do
        let(:is_frontend) { false }
        it_behaves_like :failed_resource_change
      end
    end
  end

  describe '#destroy' do
    let(:make_request) do
      delete :destroy, params: { id: summary.id }, format: :json
    end

    context 'success', :show_in_doc do
      subject! { make_request }
      it do
        expect(response).to have_http_status :success
        expect(response.content_type).to eq 'application/json'
        expect(json[:notice]).to eq 'Отзыв удалён'
      end
    end

    context 'forbidden' do
      let(:summary) { create :summary, user: user_admin, anime: anime }
      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end
  end
end
