describe Api::V1::DevicesController, :show_in_doc do
  include_context :authenticated

  describe '#index' do
    let!(:device_1) { create :device, user: user }
    let!(:device_2) { create :device, user: user_2 }
    subject! { get :index, format: :json }

    it do
      expect(assigns(:devices)).to eq [device_1]
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(response).to have_http_status :success
    end
  end

  describe '#create' do
    subject! { post :create, params: { device: params }, format: :json }
    let(:params) do
      {
        user_id: user.id,
        token: 'test',
        platform: 'ios',
        name: 'test'
      }
    end

    it do
      expect(assigns(:device)).to be_persisted
      expect(assigns(:device)).to have_attributes params
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(response).to have_http_status :created
    end
  end

  describe '#update' do
    subject! do
      patch :update, params: { id: device.id, device: params }, format: :json
    end
    let(:device) { create :device, user: user }
    let(:params) { { token: 'test zxc' } }

    it do
      expect(assigns :device).to have_attributes params
      expect(response.content_type).to eq 'application/json; charset=utf-8'
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
