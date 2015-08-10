describe Versioneer do
  let(:service) { Versioneer.new anime }
  let(:anime) { create :anime, name: 'test', episodes: 3, episodes_aired: 5 }
  let(:changes) {{ name: 'zzz', episodes: 7, episodes_aired: 5 }}
  let(:author) { build_stubbed :user }
  let(:reason) { 'change reason' }

  let(:result_diff) {{ 'name' => ['test','zzz'], 'episodes' => [3,7] }}

  describe '#premoderate' do
    subject!(:version) { service.premoderate changes, author, reason }

    it do
      expect(anime.name).to eq 'test'
      expect(anime.episodes).to eq 3
      expect(anime).to_not be_changed

      expect(version).to be_persisted
      expect(version).to be_pending
      expect(version.user).to eq author
      expect(version.reason).to eq reason
      expect(version.item_diff).to eq result_diff
      expect(version.item).to eq anime
      expect(version.moderator).to be_nil
    end
  end

  describe '#postmoderate' do
    subject!(:version) { service.postmoderate changes, author, reason }

    it do
      expect(anime).to have_attributes changes
      expect(anime).to_not be_changed

      expect(version).to be_persisted
      expect(version).to be_auto_accepted
      expect(version.user).to eq author
      expect(version.reason).to eq reason
      expect(version.item_diff).to eq result_diff
      expect(version.item).to eq anime
      expect(version.moderator).to be_nil
    end
  end
end
