describe ImagesController do
  include_context :authenticated, :user
  let(:club) { create :club, owner: user }

  describe 'create' do
    pending
    #let(:image) { fixture_file_upload Rails.root.join('spec/images/anime.jpg'), 'image/jpeg' }
    #before { post :create, model: club.class.name, id: club.id, image: image }

    #it { expect(response).to have_http_status :success }
    #it { expect(response.content_type).to eq 'application/json' }
    #it { JSON.parse(response.body).should have_key 'html' }
    #it 'creates new image' do
      #expect {
        #post :create, model: club.class.name, id: club.id, image: image
      #}.to change(Image, :count).by 1
    #end
  end

  describe 'destroy' do
    let(:image) { create :image, uploader: user, owner: club }
    before { delete :destroy, id: image.id }

    it do
      expect(resource).to_not be_persisted
      expect(response).to have_http_status :success
    end
  end
end
