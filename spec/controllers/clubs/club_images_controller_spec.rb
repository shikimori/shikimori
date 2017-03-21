describe Clubs::ClubImagesController do
  include_context :authenticated, :user
  let(:club) { create :club, owner: user }
  let!(:club_role) { create :club_role, club: club, user: user, role: 'admin' }

  describe '#create' do
    let(:image) { fixture_file_upload "#{Rails.root}/spec/images/anime.jpg", 'image/jpeg' }
    before { post :create, params: { club_id: club.id, image: image } }

    it do
      expect(club.images).to have(1).item
      expect(club.images.first.user).to eq user
      expect(response).to redirect_to club_url(club)
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
