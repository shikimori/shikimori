describe UserImagesController do
  describe 'create' do
    let(:image) { fixture_file_upload Rails.root.join('spec/images/anime.jpg'), 'image/jpeg' }

    context 'guest' do
      before { post :create }
      it { should respond_with :redirect }
    end

    context 'user' do
      let(:club) { create :club }

      before do
        sign_in create(:user)
        post :create, model: club.class.name, id: club.id, image: image
      end

      it { expect(response).to have_http_status :success }
      it { expect(response.content_type).to eq 'application/json' }

      it 'creates new image' do
        expect {
          post :create, linked_type: club.class.name, linked_id: club.id, image: image
        }.to change(UserImage, :count).by 1
      end

      it { expect(JSON.parse(response.body)).to have_key 'id' }
      it { expect(JSON.parse(response.body)).to have_key 'preview' }
      it { expect(JSON.parse(response.body)).to have_key 'url' }
    end
  end
end
