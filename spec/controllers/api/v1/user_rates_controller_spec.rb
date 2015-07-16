require 'cancan/matchers'

describe Api::V1::UserRatesController do
  context 'token authentication' do
    let!(:user) { create :user, api_access_token: 'zzzxxxccc' }

    describe '#create' do
      let(:target) { create :anime }
      let(:create_params) {{ user_id: user.id, target_id: target.id, target_type: target.class.name, score: 10, status: 1, episodes: 2, volumes: 3, chapters: 4, text: 'test', rewatches: 5 }}
      before do
        @request.headers['X-User-Nickname'] = user.nickname
        @request.headers['X-User-Api-Access-Token'] = user.api_access_token
        post :create, user_rate: create_params, format: :json
      end

      it do
        expect(response).to have_http_status :created
        expect(assigns :user_rate).to have_attributes create_params.except(:status)
        expect(assigns(:user_rate).status).to eq 'watching'
      end
    end
  end

  context 'login&password authentication', :show_in_doc do
    include_context :authenticated, :user

    describe '#create' do
      let(:target) { create :anime }
      let(:create_params) {{ user_id: user.id, target_id: target.id, target_type: target.class.name, score: 10, status: 1, episodes: 2, volumes: 3, chapters: 4, text: 'test', rewatches: 5 }}
      before { post :create, user_rate: create_params, format: :json }

      it do
        expect(response).to have_http_status :created
        expect(assigns :user_rate).to have_attributes create_params.except(:status)
        expect(assigns(:user_rate).status).to eq 'watching'
      end
    end

    describe '#update' do
      let(:user_rate) { create :user_rate, user: user }
      let(:update_params) {{ score: 10, status: 1, episodes: 2, volumes: 3, chapters: 4, text: 'test', rewatches: 5 }}
      before { patch :update, id: user_rate.id, user_rate: update_params, format: :json }

      it do
        expect(response).to have_http_status :success
        expect(assigns :user_rate).to have_attributes update_params.except(:status)
        expect(assigns(:user_rate).status).to eq 'watching'
      end
    end

    describe '#increment' do
      let(:user_rate) { create :user_rate, user: user, episodes: 1 }
      before { post :increment, id: user_rate.id, format: :json }

      it do
        expect(response).to have_http_status :created
        expect(assigns(:user_rate).episodes).to eq user_rate.episodes + 1
      end
    end

    describe '#destroy' do
      let(:user_rate) { create :user_rate, user: user }
      before { delete :destroy, id: user_rate.id, format: :json }

      it do
        expect(response).to have_http_status :no_content
        expect(assigns(:user_rate)).to be_new_record
      end
    end

    describe '#cleanup' do
      let!(:user_rate) { create :user_rate, user: user, target: entry }
      let!(:user_history) { create :user_history, user: user, target: entry }

      context 'anime' do
        let(:entry) { create :anime }
        before { delete :cleanup, type: :anime }

        it do
          expect(response).to have_http_status :success
          expect(user.anime_rates).to be_empty
          expect(user.history).to be_empty
        end
      end

      context 'manga' do
        let(:entry) { create :manga }
        before { delete :cleanup, type: :manga }

        it do
          expect(response).to have_http_status :success
          expect(user.manga_rates).to be_empty
          expect(user.history).to be_empty
        end
      end
    end

    describe '#reset' do
      let!(:user_rate) { create :user_rate, user: user, target: entry, score: 1 }

      context 'anime' do
        let(:entry) { create :anime }
        before { post :reset, type: :anime }

        it do
          expect(response).to have_http_status :success
          expect(user_rate.reload.score).to be_zero
        end
      end

      context 'manga' do
        let(:entry) { create :manga }
        before { post :reset, type: :manga }

        it do
          expect(response).to have_http_status :success
          expect(user_rate.reload.score).to be_zero
        end
      end
    end

    describe 'permissions' do
      subject { Ability.new user }

      context 'own_data' do
        let(:user_rate) { build :user_rate, user: user }

        it { should be_able_to :manage, user_rate }
        it { should be_able_to :clenaup, user_rate }
        it { should be_able_to :reset, user_rate }
      end

      context 'foreign_data' do
        let(:user_rate) { build :user_rate, user: build_stubbed(:user) }

        it { should_not be_able_to :manage, user_rate }
      end

      context 'guest' do
        subject { Ability.new nil }
        let(:user_rate) { build :user_rate, user: user }

        it { should_not be_able_to :manage, user_rate }
        it { should_not be_able_to :clenaup, user_rate }
        it { should_not be_able_to :reset, user_rate }
      end
    end
  end
end
