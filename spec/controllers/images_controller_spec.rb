describe ImagesController do
  include_context :authenticated
  let(:club) { create :group, owner: user }

  describe :create do
    pending
    #let(:image) { fixture_file_upload Rails.root.join('spec/images/anime.jpg'), 'image/jpeg' }
    #before { post :create, model: club.class.name, id: club.id, image: image }

    #it { should respond_with 200 }
    #it { should respond_with_content_type :json }
    #it { JSON.parse(response.body).should have_key 'html' }
    #it 'creates new image' do
      #expect {
        #post :create, model: group.class.name, id: group.id, image: image
      #}.to change(Image, :count).by 1
    #end
  end

  describe :destroy do
    let(:image) { create :image, uploader: user, owner: club }
    before { delete :destroy, id: image.id }

    it { should respond_with :success }
    it { expect(resource).to_not be_persisted }
  end
end
