describe Api::V1::UserImagesController do
  describe '#create' do
    let(:image) do
      Rack::Test::UploadedFile.new(
        "#{Rails.root}/spec/files/anime.jpg",
        'image/jpeg'
      )
    end

    context 'guest' do
      before { post :create }
      it { should respond_with :redirect }
    end

    context 'authenticated' do
      include_context :authenticated, :user

      describe 'upload test' do
        before do
          post :create, params: {
            model: club.class.name,
            id: club.id,
            image: image
          }
        end

        it do
          expect(json).to have_key :id
          expect(json).to have_key :preview
          expect(json).to have_key :url
          expect(json).to have_key :bbcode

          expect(user.user_images).to have(1).item

          expect(response).to have_http_status :success
          expect(response.content_type).to eq 'application/json; charset=utf-8'
        end
      end

      describe 'documentation', :show_in_doc do
        before { allow(controller).to receive(:uploaded_image).and_return image }
        before { post :create, params: { linked_type: 'Comment', image: 'uploaded file' } }
        it { expect(response).to have_http_status :success }
      end
    end
  end
end
