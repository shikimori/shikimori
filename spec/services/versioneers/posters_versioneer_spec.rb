describe Versioneers::PostersVersioneer do
  let(:service) { Versioneers::PostersVersioneer.new anime }
  let(:anime) { create :anime }
  let(:image) { Rack::Test::UploadedFile.new 'spec/files/anime.jpg', 'image/jpg' }
  let(:author) { build_stubbed :user }
  let(:reason) { 'change reason' }

  describe '#premoderate' do
    subject!(:version) { service.premoderate image, author, reason }

    it do
      expect(anime.image).to be_present
      expect(anime).to_not be_changed

      expect(version).to be_persisted
      expect(version).to be_pending
      expect(version).to be_instance_of Versions::PosterVersion
      expect(version).to have_attributes(
        user: author,
        reason: reason,
        item_diff: { 'image' => [nil, 'anime.jpg'] },
        item: anime,
        moderator: nil
      )
    end
  end

  describe '#postmoderate' do
    subject(:version) { service.postmoderate image, author, reason }

    it do
      expect { subject }.to raise_error 'not implemented'
      # expect(anime.image).to be_present
      # expect(anime).to_not be_changed
      #
      # expect(version).to be_persisted
      # expect(version).to be_auto_accepted
      # expect(version).to be_instance_of Versions::PosterVersion
      # expect(version).to have_attributes(
      #   user: author,
      #   reason: reason,
      #   item_diff: { 'image' => [nil, 'anime.jpg'] },
      #   item: anime,
      #   moderator: author
      # )
    end
  end
end
