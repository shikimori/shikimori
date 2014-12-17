describe UserImagesController do
  describe 'create' do
    let(:image) { fixture_file_upload Rails.root.join('spec/images/anime.jpg'), 'image/jpeg' }

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
      it { expect(response.content_type).to eq 'application/json' }

      it 'creates new image' do
        expect {
          post :create, linked_type: group.class.name, linked_id: group.id, image: image
        }.to change(UserImage, :count).by 1
      end

      it { expect(JSON.parse(response.body)).to have_key 'id' }
      it { expect(JSON.parse(response.body)).to have_key 'preview' }
      it { expect(JSON.parse(response.body)).to have_key 'url' }
    end
  end
end
