require 'cancan/matchers'

describe Api::V2::UserRatesController, :show_in_doc do
  include_context :authenticated, :user

  before do
    allow(Achievements::Track).to receive :perform_async
    allow(UserRates::Log).to receive :call
  end

  describe '#show' do
    let(:user_rate) { create :user_rate, user: user }
    before { get :show, params: { id: user_rate.id }, format: :json }

    it { expect(response).to have_http_status :success }
  end

  describe '#index' do
    let!(:user_rate_1) { create :user_rate, :completed, user: user }
    let!(:user_rate_2) { create :user_rate, :planned, user: user }
    let!(:user_rate_3) { create :user_rate, :watching, user: user }
    before do
      get :index,
        params: {
          user_id: user.id,
          status: 'completed,planned'
        },
        format: :json
    end

    it do
      expect(json).to have(2).items
      expect(response).to have_http_status :success
    end
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
    let(:make_request) { post :create, params: { user_rate: create_params }, format: :json }

    context 'new user_rate' do
      before { make_request }

      it do
        expect(resource).to be_persisted
        expect(resource).to_not be_changed
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
      before { make_request }

      it do
        expect(resource).to have_attributes create_params
        expect(resource.id).to eq user_rate.id

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
  end

  describe '#update' do
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

  describe '#increment' do
    let(:user_rate) { create :user_rate, user: user, episodes: 1 }
    before { post :increment, params: { id: user_rate.id }, format: :json }

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

  describe '#destroy' do
    let(:user_rate) { create :user_rate, %i[planned completed].sample, user: user }
    before { delete :destroy, params: { id: user_rate.id }, format: :json }

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
end
