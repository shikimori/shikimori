require 'spec_helper'

describe ImagesController do
  describe :create do
    let(:image) { fixture_file_upload Rails.root.join('spec/images/anime.jpg'), 'image/jpeg' }

    context 'guest' do
      before { post :create }
      it { should respond_with(302) }
    end

    context 'user' do
      let(:group) { create :group }

      before do
        sign_in create(:user)
        post :create, model: group.class.name, id: group.id, image: image
      end

      it { should respond_with 200 }
      it { should respond_with_content_type :json }
      it { JSON.parse(response.body).should have_key 'html' }
      it 'creates new image' do
        expect {
          post :create, model: group.class.name, id: group.id, image: image
        }.to change(Image, :count).by 1
      end
    end
  end
end
