describe Versioneers::PostersVersioneer do
  let(:service) { Versioneers::PostersVersioneer.new anime }
  let(:anime) { create :anime }
  let(:image) { Rack::Test::UploadedFile.new 'spec/images/anime.jpg', 'image/jpg' }
  let(:author) { build_stubbed :user }
  let(:reason) { 'change reason' }

  describe '#postmoderate' do
    subject!(:version) { service.postmoderate image, author, reason }

    it do
      expect(anime.image).to be_present
      expect(anime).to_not be_changed

      expect(version).to be_persisted
      expect(version).to be_auto_accepted
      expect(version.class).to eq Versions::PosterVersion
      expect(version.user).to eq author
      expect(version.reason).to eq reason
      expect(version.item_diff).to eq 'image' => []
      expect(version.item).to eq anime
      expect(version.moderator).to be_nil
    end
  end
end
