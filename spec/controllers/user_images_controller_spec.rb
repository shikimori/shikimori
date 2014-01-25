require 'spec_helper'

describe UserImagesController do
  describe :create do
    let(:image) { Rack::Test::UploadedFile.new(Rails.root + 'spec/images/anime.jpg') }

    context 'guest' do
      before { post :create }
      it { should respond_with :redirect }
    end

    context 'user' do
      let(:group) { create :group }

      before do
        sign_in create(:user)
        post :create, model: group.class.name, id: group.id, image: image
      end

      it { should respond_with :success }
      it { should respond_with_content_type :json }

      it 'creates new image' do
        expect {
          post :create, linked_type: group.class.name, linked_id: group.id, image: image
        }.to change(UserImage, :count).by 1
      end

      it { JSON.parse(response.body).should have_key 'id' }
      it { JSON.parse(response.body).should have_key 'preview' }
      it { JSON.parse(response.body).should have_key 'url' }
    end
  end
end
