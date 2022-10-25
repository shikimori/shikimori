describe Api::V1::UserRatesController do
  before do
    allow(Achievements::Track).to receive :perform_async
    allow(UserRates::Log).to receive :call
  end

  context 'login&password authentication' do
    include_context :authenticated, :user

    describe '#show', :show_in_doc do
      let(:user_rate) { create :user_rate, user: user }
      subject! { get :show, params: { id: user_rate.id }, format: :json }

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
          status: %w[watching completed].sample,
          episodes: 2,
          volumes: 3,
          chapters: 4,
          text: 'test',
          rewatches: 5
        }
      end
      let(:make_request) do
        post :create,
          params: {
            user_rate: create_params
          },
          format: :json
      end

      context 'new user_rate', :show_in_doc do
        subject! { make_request }

        it do
          expect(resource).to be_persisted
          expect(resource).to have_attributes create_params

          expect(UserRates::Log)
            .to have_received(:call)
            .with(
              user_rate: resource,
              ip: controller.send(:request).remote_ip,
              user_agent: request.user_agent,
              oauth_application_id: controller.send(:doorkeeper_token)&.application_id
            )

          expect(Achievements::Track)
            .to have_received(:perform_async)
            .with resource.user_id, resource.id, Types::Neko::Action[:put]

          expect(response).to have_http_status :success
        end
      end

      context 'present user_rate' do
        let!(:user_rate) { create :user_rate, user: user, target: target }
        subject! { make_request }

        it do
          expect(resource).to have_attributes create_params
          expect(resource.id).to eq user_rate.id

          expect(Achievements::Track)
            .to have_received(:perform_async)
            .with resource.user_id, resource.id, Types::Neko::Action[:put]

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
      subject! do
        patch :update,
          params: {
            id: user_rate.id,
            user_rate: update_params
          },
          format: :json
      end

      it do
        expect(resource).to have_attributes update_params

        expect(UserRates::Log)
          .to have_received(:call)
          .with(
            user_rate: resource,
            ip: controller.send(:request).remote_ip,
            user_agent: request.user_agent,
            oauth_application_id: controller.send(:doorkeeper_token)&.application_id
          )

        expect(Achievements::Track)
          .to have_received(:perform_async)
          .with resource.user_id, resource.id, Types::Neko::Action[:put]

        expect(response).to have_http_status :success
      end
    end

    describe '#increment', :show_in_doc do
      let(:user_rate) { create :user_rate, user: user, episodes: 1 }
      subject! { post :increment, params: { id: user_rate.id }, format: :json }

      it do
        expect(resource.episodes).to eq user_rate.episodes + 1

        expect(UserRates::Log)
          .to have_received(:call)
          .with(
            user_rate: resource,
            ip: controller.send(:request).remote_ip,
            user_agent: request.user_agent,
            oauth_application_id: controller.send(:doorkeeper_token)&.application_id
          )

        expect(Achievements::Track)
          .to have_received(:perform_async)
          .with resource.user_id, resource.id, Types::Neko::Action[:put]

        expect(response).to have_http_status :created
      end
    end

    describe '#destroy', :show_in_doc do
      let(:user_rate) { create :user_rate, %i[planned completed].sample, user: user }
      subject! { delete :destroy, params: { id: user_rate.id }, format: :json }

      it do
        expect(resource).to be_destroyed

        expect(UserRates::Log)
          .to have_received(:call)
          .with(
            user_rate: resource,
            ip: controller.send(:request).remote_ip,
            user_agent: request.user_agent,
            oauth_application_id: controller.send(:doorkeeper_token)&.application_id
          )

        expect(Achievements::Track)
          .to have_received(:perform_async)
          .with resource.user_id, resource.id, Types::Neko::Action[:delete]

        expect(response).to have_http_status :no_content
      end
    end

    describe '#cleanup' do
      let!(:user_rate) { create :user_rate, user: user, target: entry }
      let!(:user_history) { create :user_history, user: user, (entry.anime? ? :anime : :manga) => entry }

      context 'anime', :show_in_doc do
        let(:entry) { create :anime }
        subject! { delete :cleanup, params: { type: :anime } }

        it do
          expect(user.anime_rates).to be_empty
          expect(user.history).to be_empty

          expect(Achievements::Track)
            .to have_received(:perform_async)
            .with user.id, nil, Types::Neko::Action[:reset]

          expect(json[:notice]).to eq 'Выполнена очистка твоего списка аниме и твоей истории по аниме'
          expect(response).to have_http_status :success
        end
      end

      context 'manga' do
        let(:entry) { create :manga }
        subject! { delete :cleanup, params: { type: :manga } }

        it do
          expect(user.manga_rates).to be_empty
          expect(user.history).to be_empty

          expect(Achievements::Track).to_not have_received :perform_async

          expect(json[:notice]).to eq 'Выполнена очистка твоего списка манги и твоей истории по манге'
          expect(response).to have_http_status :success
        end
      end
    end

    describe '#reset' do
      let!(:user_rate) { create :user_rate, user: user, target: entry, score: 1 }

      context 'anime', :show_in_doc do
        let(:entry) { create :anime }
        subject! { delete :reset, params: { type: :anime } }

        it do
          expect(user_rate.reload.score).to be_zero

          expect(Achievements::Track)
            .to have_received(:perform_async)
            .with user.id, nil, Types::Neko::Action[:reset]

          expect(json[:notice]).to eq 'Выполнен сброс оценок в вашем списке аниме'
          expect(response).to have_http_status :success
        end
      end

      context 'manga' do
        let(:entry) { create :manga }
        subject! { delete :reset, params: { type: :manga } }

        it do
          expect(user_rate.reload.score).to be_zero

          expect(Achievements::Track).to_not have_received :perform_async

          expect(json[:notice]).to eq 'Выполнен сброс оценок в вашем списке манги'
          expect(response).to have_http_status :success
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
