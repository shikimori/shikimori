describe Api::V1::UserRatesController do
  before { allow(Achievements::Track).to receive :perform_async }

  context 'token authentication' do
    let!(:user) { create :user, api_access_token: 'zzzxxxccc' }

    describe '#create' do
      let(:target) { create :anime }
      let(:create_params) do
        {
          user_id: user.id,
          target_id: target.id,
          target_type: target.class.name,
          score: 10,
          status: 'watching',
          episodes: 2,
          volumes: 3,
          chapters: 4,
          text: 'test',
          rewatches: 5
        }
      end
      before do
        @request.headers['X-User-Nickname'] = user.nickname
        @request.headers['X-User-Api-Access-Token'] = user.api_access_token
        post :create, params: { user_rate: create_params }, format: :json
      end

      it do
        expect(resource).to be_persisted
        expect(resource).to have_attributes create_params

        expect(Achievements::Track)
          .to have_received(:perform_async)
          .with resource.user_id, resource.id, Types::Neko::Action[:create]

        expect(response).to have_http_status :success
      end
    end
  end

  context 'login&password authentication' do
    include_context :authenticated, :user

    describe '#show', :show_in_doc do
      let(:user_rate) { create :user_rate, user: user }
      before { get :show, params: { id: user_rate.id }, format: :json }

      it { expect(response).to have_http_status :success }
    end

    describe '#create' do
      let(:target) { create :anime }
      let(:create_params) do
        {
          user_id: user.id,
          target_id: target.id,
          target_type: target.class.name,
          score: 10,
          status: 'watching',
          episodes: 2,
          volumes: 3,
          chapters: 4,
          text: 'test',
          rewatches: 5
        }
      end
      let(:make_request) { post :create, params: { user_rate: create_params }, format: :json }

      context 'new user_rate', :show_in_doc do
        before { make_request }

        it do
          expect(resource).to be_persisted
          expect(resource).to have_attributes create_params

          expect(Achievements::Track)
            .to have_received(:perform_async)
            .with resource.user_id, resource.id, Types::Neko::Action[:create]

          expect(response).to have_http_status :success
        end
      end

      context 'present user_rate' do
        let!(:user_rate) { create :user_rate, user: user, target: target }
        before { make_request }

        it do
          expect(resource).to have_attributes create_params
          expect(resource.id).to eq user_rate.id

          expect(Achievements::Track)
            .to have_received(:perform_async)
            .with resource.user_id, resource.id, Types::Neko::Action[:update]

          expect(response).to have_http_status :success
        end
      end
    end

    describe '#update', :show_in_doc do
      let(:user_rate) { create :user_rate, user: user }
      let(:update_params) do
        {
          score: 10,
          status: 'watching',
          episodes: 2,
          volumes: 3,
          chapters: 4,
          text: 'test',
          rewatches: 5
        }
      end
      before { patch :update, params: { id: user_rate.id, user_rate: update_params }, format: :json }

      it do
        expect(resource).to have_attributes update_params

        expect(Achievements::Track)
          .to have_received(:perform_async)
          .with resource.user_id, resource.id, Types::Neko::Action[:update]

        expect(response).to have_http_status :success
      end
    end

    describe '#increment', :show_in_doc do
      let(:user_rate) { create :user_rate, user: user, episodes: 1 }
      before { post :increment, params: { id: user_rate.id }, format: :json }

      it do
        expect(resource.episodes).to eq user_rate.episodes + 1

        expect(Achievements::Track)
          .to have_received(:perform_async)
          .with resource.user_id, resource.id, Types::Neko::Action[:update]

        expect(response).to have_http_status :created
      end
    end

    describe '#destroy', :show_in_doc do
      let(:user_rate) { create :user_rate, user: user }
      before { delete :destroy, params: { id: user_rate.id }, format: :json }

      it do
        expect(resource).to be_destroyed

        expect(Achievements::Track)
          .to have_received(:perform_async)
          .with resource.user_id, resource.id, Types::Neko::Action[:destroy]

        expect(response).to have_http_status :no_content
      end
    end

    describe '#cleanup' do
      let!(:user_rate) { create :user_rate, user: user, target: entry }
      let!(:user_history) { create :user_history, user: user, target: entry }

      context 'anime', :show_in_doc do
        let(:entry) { create :anime }
        before { delete :cleanup, params: { type: :anime } }

        it do
          expect(response).to have_http_status :success
          expect(user.anime_rates).to be_empty
          expect(user.history).to be_empty
          expect(json[:notice]).to eq 'Выполнена очистка вашего списка аниме и вашей истории по аниме'
        end
      end

      context 'manga' do
        let(:entry) { create :manga }
        before { delete :cleanup, params: { type: :manga } }

        it do
          expect(response).to have_http_status :success
          expect(user.manga_rates).to be_empty
          expect(user.history).to be_empty
          expect(json[:notice]).to eq 'Выполнена очистка вашего списка манги и вашей истории по манге'
        end
      end
    end

    describe '#reset' do
      let!(:user_rate) { create :user_rate, user: user, target: entry, score: 1 }

      context 'anime', :show_in_doc do
        let(:entry) { create :anime }
        before { post :reset, params: { type: :anime } }

        it do
          expect(response).to have_http_status :success
          expect(user_rate.reload.score).to be_zero
          expect(json[:notice]).to eq 'Выполнен сброс оценок в вашем списке аниме'
        end
      end

      context 'manga' do
        let(:entry) { create :manga }
        before { post :reset, params: { type: :manga } }

        it do
          expect(response).to have_http_status :success
          expect(user_rate.reload.score).to be_zero
          expect(json[:notice]).to eq 'Выполнен сброс оценок в вашем списке манги'
        end
      end
    end

    describe 'permissions' do
      subject { Ability.new user }

      context 'own_data' do
        let(:user_rate) { build :user_rate, user: user }

        it { is_expected.to be_able_to :manage, user_rate }
        it { is_expected.to be_able_to :clenaup, user_rate }
        it { is_expected.to be_able_to :reset, user_rate }
      end

      context 'foreign_data' do
        let(:user_rate) { build :user_rate, user: build_stubbed(:user) }

        it { is_expected.to_not be_able_to :manage, user_rate }
      end

      context 'guest' do
        subject { Ability.new nil }
        let(:user_rate) { build :user_rate, user: user }

        it { is_expected.to_not be_able_to :manage, user_rate }
        it { is_expected.to_not be_able_to :clenaup, user_rate }
        it { is_expected.to_not be_able_to :reset, user_rate }
      end
    end
  end
end
