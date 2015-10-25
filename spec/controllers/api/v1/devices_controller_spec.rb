require 'cancan/matchers'

describe Api::V1::DevicesController, :show_in_doc do
  include_context :authenticated, :user
  let(:user) { create :user, :user }

  describe '#index' do
    let!(:device_1) { create :device, user: user }
    let!(:device_2) { create :device }
    before { get :index, format: :json }

    it do
      expect(assigns(:devices)).to have(1).item
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end

  describe '#create' do
    let(:params) {{ user_id: user.id, token: 'test', platform: 'ios', name: 'test'}}
    before { post :create, device: params, format: :json }

    it do
      expect(assigns :device).to be_persisted
      expect(assigns :device).to have_attributes params
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :created
    end
  end

  describe '#update' do
    let(:device) { create :device, user: user }
    let(:params) {{ token: 'test zxc' }}
    before { patch :update, id: device.id, device: params, format: :json }

    it do
      expect(assigns :device).to have_attributes params
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end

  describe '#destroy' do
    let(:device) { create :device, user: user }
    before { delete :destroy, id: device.id, format: :json }

    it do
      expect(assigns :device).to be_destroyed
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :no_content
    end
  end

  describe 'permissions' do
    subject { Ability.new user }

    context 'own_device' do
      let(:device) { build :device, user: user }
      it { should be_able_to :manage, device }
    end

    context 'foreign_device' do
      let(:device) { build :device }
      it { should_not be_able_to :manage, device }
    end

    context 'guest' do
      subject { Ability.new nil }
      let(:device) { build :device, user: user }
      it { should_not be_able_to :manage, device }
    end
  end
end
