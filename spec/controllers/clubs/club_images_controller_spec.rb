describe Clubs::ClubImagesController do
  include_context :authenticated, :user
  let(:club) { create :club, owner: user }
  let!(:club_role) { create :club_role, club: club, user: user, role: 'admin' }

  describe '#create' do
    let(:image) do
      fixture_file_upload "#{Rails.root}/spec/images/anime.jpg", 'image/jpeg'
    end
    before do
      post :create,
        params: { club_id: club.id, image: image },
        xhr: is_xhr
    end

    context 'not xhr' do
      let(:is_xhr) { false }
      it do
        expect(resource).to be_persisted
        expect(resource).to have_attributes(
          club_id: club.id,
          user_id: user.id
        )
        expect(response).to redirect_to club_url(club)
      end
    end

    context 'xhr' do
      let(:is_xhr) { true }
      it do
        expect(resource).to be_persisted
        expect(resource).to have_attributes(
          club_id: club.id,
          user_id: user.id
        )
        expect(json).to eq JSON.parse(
          ClubImageSerializer.new(resource).to_json
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
