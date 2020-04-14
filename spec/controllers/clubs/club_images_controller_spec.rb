describe Clubs::ClubImagesController do
  include_context :authenticated, :user, :week_registered
  let(:club) { create :club, owner: user }
  let!(:club_role) { create :club_role, club: club, user: user, role: 'admin' }

  describe '#create' do
    let(:image) do
      Rack::Test::UploadedFile.new(
        "#{Rails.root}/spec/files/anime.jpg",
        'image/jpeg'
      )
    end

    context 'not xhr' do
      let(:image_2) do
        Rack::Test::UploadedFile.new(
          "#{Rails.root}/spec/files/anime.jpg",
          'image/jpeg'
        )
      end

      before do
        post :create,
          params: {
            club_id: club.id,
            images: [image, image_2]
          }
      end

      it do
        expect(club.images).to have(2).items
        expect(club.images.first).to be_persisted
        expect(club.images.first).to have_attributes(
          club_id: club.id,
          user_id: user.id
        )
        expect(response).to redirect_to club_url(club)
      end
    end

    context 'xhr' do
      before do
        post :create,
          params: {
            club_id: club.id,
            image: image
          },
          xhr: true
      end

      it do
        expect(resource).to be_persisted
        expect(resource).to have_attributes(
          club_id: club.id,
          user_id: user.id
        )
        expect(json).to eq JSON.parse(
          ClubImageSerializer.new(resource, scope: controller.view_context).to_json
        ).symbolize_keys
        expect(response).to have_http_status :success
      end
    end
  end

  describe 'destroy' do
    let(:image) { create :club_image, user: user, club: club }
    before { delete :destroy, params: { club_id: club.id, id: image.id } }

    it do
      expect(resource).to_not be_persisted
      expect(response).to have_http_status :success
    end
  end
end
