describe Versioneers::VideosVersioneer do
  let(:versioneer) { Versioneers::VideosVersioneer.new anime }
  let(:anime) { create :anime }
  let(:user) { create :user }

  describe '#upload',:focus do
    let(:params) {{
      url: 'http://youtube.com/watch?v=l1YX30AmYsA',
      name: 'test',
      kind: Video::PV,
      uploader_id: user.id
    }}

    subject!(:result) { versioneer.upload params, user }

    let(:video) { result.first }
    let(:version) { result.second }

    it do
      expect(video).to be_persisted
      expect(video).to be_uploaded
      expect(video).to have_attributes(
        url: params[:url],
        name: params[:name],
        kind: params[:kind],
        uploader: user,
        anime: anime
      )

      expect(version).to be_persisted
      expect(version).to have_attributes(
        item: anime,
        item_diff: {
          'action' => Versioneers::VideosVersioneer::UPLOAD,
          Versioneers::VideosVersioneer::KEY => [video.id]
        },
        user: user,
      )
    end
  end

  describe '#reposition' do
    it { expect{versioneer.reposition nil, nil}.to raise_error NotImplementedError }
  end

  describe '#delete' do
    let(:video) { build_stubbed :video }
    subject!(:version) { versioneer.delete video.id, user }

    it do
      expect(version).to be_persisted
      expect(version).to have_attributes(
        item: anime,
        item_diff: {
          'action' => Versioneers::VideosVersioneer::DELETE,
          Versioneers::VideosVersioneer::KEY => [video.id]
        },
        user: user,
      )
    end
  end
end
