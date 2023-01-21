describe Versioneers::VideosVersioneer do
  let(:versioneer) { described_class.new anime }
  let(:anime) { create :anime }

  describe '#upload' do
    let(:params) do
      {
        url: 'https://youtube.com/watch?v=l1YX30AmYsA',
        name: 'test',
        kind: 'pv',
        uploader_id: user.id
      }
    end

    subject!(:result) { versioneer.upload params, user }

    let(:video) { result.first }
    let(:version) { result.second }

    it do
      expect(video).to be_persisted
      expect(video).to_not be_changed
      expect(video).to be_uploaded
      expect(video).to have_attributes(
        url: params[:url],
        name: params[:name],
        kind: params[:kind],
        uploader: user,
        anime: anime
      )

      expect(version).to be_persisted
      expect(version).to_not be_changed
      expect(version).to have_attributes(
        item: anime,
        item_diff: {
          'action' => described_class::UPLOAD.to_s,
          described_class::KEY => [video.id]
        },
        user: user
      )
    end
  end

  describe '#reposition' do
    it { expect { versioneer.reposition nil, nil }.to raise_error NotImplementedError }
  end

  describe '#delete' do
    let(:video) { build_stubbed :video }
    subject!(:version) { versioneer.delete video.id, user }

    it do
      expect(version).to be_persisted
      expect(version).to_not be_changed
      expect(version).to have_attributes(
        item: anime,
        item_diff: {
          'action' => described_class::DELETE.to_s,
          described_class::KEY => [video.id]
        },
        user: user
      )
    end
  end
end
