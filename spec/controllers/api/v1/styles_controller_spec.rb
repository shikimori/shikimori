require 'cancan/matchers'

describe Api::V1::StylesController, :show_in_doc do
  include_context :authenticated, :user

  describe '#show' do
    let(:style) { create :style, owner: user }
    subject! { patch :show, params: { id: style.id }, format: :json }

    it do
      expect(resource).to eq style
      expect(response).to have_http_status :success
    end
  end

  describe '#preview' do
    let(:preview_params) { { css: 'xxx' } }
    subject! { post :preview, params: { style: preview_params }, format: :json }

    it do
      expect(resource).to have_attributes preview_params
      expect(resource).to be_new_record
      expect(response).to have_http_status :success
    end
  end

  describe '#create' do
    let(:create_params) do
      {
        owner_id: user.id,
        owner_type: User.name,
        name: 'zzz',
        css: 'xxx'
      }
    end
    subject! { post :create, params: { style: create_params }, format: :json }

    it do
      expect(resource).to have_attributes create_params
      expect(resource).to be_persisted
      expect(resource).to_not be_changed
      expect(response).to have_http_status :success
    end
  end

  describe '#update' do
    let(:style) { create :style, owner: user }
    let(:update_params) do
      {
        name: 'zzz',
        css: 'xxx'
      }
    end
    subject! { patch :update, params: { id: style.id, style: update_params }, format: :json }

    it do
      expect(resource).to have_attributes update_params
      expect(resource).to_not be_changed
      expect(response).to have_http_status :success
    end
  end

  # describe '#destroy' do
    # let(:style) { create :style, owner: user }
    # before { delete :destroy, id: style.id, format: :json }

    # it do
      # expect(resource).to be_destroyed
      # expect(response).to have_http_status :no_content
    # end
  # end
end
