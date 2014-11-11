describe VideosController, :type => :controller do
  before do
    allow_any_instance_of(Video).to receive :existence
    sign_in user
  end

  let(:user) { create :user, id: 1 }

  let(:url) { 'http://youtube.com/watch?v=l1YX30AmYsA' }
  let(:name) { 'test' }
  let(:kind) { Video::PV }
  let(:anime_id) { create(:anime).id }

  let(:json) { JSON.parse response.body }

  describe :create do
    describe 'response' do
      before { post :create, id: anime_id, video: { url: url, kind: kind, name: name } }

      it { should respond_with 200 }
      it { should respond_with_content_type :json }
    end

    describe 'apply' do
      before do
        request.env["HTTP_REFERER"] = anime_url(anime_id)
        post :create, id: anime_id, apply: 1, video: { url: url, kind: kind, name: name }
      end
      it { should redirect_to request.env['HTTP_REFERER'] }
    end

    describe 'apply wo_permissions' do
      before do
        sign_in create(:user, id: 9999)
        post :create, id: anime_id, apply: 1, video: { url: url, kind: kind, name: name }
      end
      it { should respond_with 200 }
    end

    it 'creates video' do
      expect {
        post :create, id: anime_id, video: { url: url, kind: kind, name: name }
      }.to change(Video, :count).by 1
    end

    describe :assigns do
      before { post :create, id: anime_id, video: { url: url, kind: kind, name: name } }
      it { expect(assigns(:video).url).to eq url }
      it { expect(assigns(:video).name).to eq name }
      it { expect(assigns(:video).kind).to eq kind }
      it { expect(assigns(:video).anime_id).to eq anime_id }
      it { expect(assigns(:video).uploader_id).to eq user.id }
    end
  end

  describe :destroy do
    let(:video) { create :video, state: 'confirmed' }
    before { post :destroy, id: video.id }

    it { should respond_with 200 }
    it { should respond_with_content_type :json }

    it 'suggest video deletion' do
      expect {
        post :destroy, id: video.id
      }.to change(UserChange.where(action: UserChange::VideoDeletion), :count).by 1
    end
  end
end
