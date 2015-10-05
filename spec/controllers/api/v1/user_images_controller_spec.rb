describe Api::V1::UserImagesController do
  describe '#create' do
    let(:image) { fixture_file_upload Rails.root.join('spec/images/anime.jpg'), 'image/jpeg' }

    context 'guest' do
      before { post :create }
      it { should respond_with :redirect }
    end

    context 'authenticated' do
      include_context :authenticated, :user
      let(:group) { create :group }

      describe 'upload test' do
        before { post :create, model: group.class.name, id: group.id, image: image }

        it do
          expect(json).to have_key :id
          expect(json).to have_key :preview
          expect(json).to have_key :url
          expect(json).to have_key :bbcode

          expect(user.user_images).to have(1).item

          expect(response).to have_http_status :success
          expect(response.content_type).to eq 'application/json'
        end
      end

      describe 'documentation', :show_in_doc do
        before { allow(controller).to receive(:uploaded_image).and_return image }
        before { post :create, linked_type: 'Comment', image: 'uploaded file' }
        it { expect(response).to have_http_status :success }
      end
    end
  end
end
