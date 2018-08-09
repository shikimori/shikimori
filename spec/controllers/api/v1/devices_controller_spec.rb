describe Api::V1::DevicesController, :show_in_doc do
  include_context :authenticated, :user

  describe '#index' do
    let!(:device_1) { create :device, user: user }
    let!(:device_2) { create :device }
    subject! { get :index, format: :json }

    it do
      expect(assigns(:devices)).to have(1).item
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end

  describe '#create' do
    let(:params) do
      { user_id: user.id, token: 'test', platform: 'ios', name: 'test' }
    end
    subject! { post :create, params: { device: params }, format: :json }

    it do
      expect(assigns(:device)).to be_persisted
      expect(assigns(:device)).to have_attributes params
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :created
    end
  end

  describe '#update' do
    let(:device) { create :device, user: user }
    let(:params) { { token: 'test zxc' } }
    subject! do
      patch :update, params: { id: device.id, device: params }, format: :json
    end

    it do
      expect(assigns :device).to have_attributes params
      expect(response.content_type).to eq 'application/json'
      expect(response).to have_http_status :success
    end
  end

  describe '#destroy' do
    let(:device) { create :device, user: user }
    subject! { delete :destroy, params: { id: device.id }, format: :json }

    it do
      expect(assigns(:device)).to be_destroyed
      expect(response).to have_http_status :no_content
    end
  end
end
