describe Versioneers::FieldsVersioneer do
  let(:service) { Versioneers::FieldsVersioneer.new anime }
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
      expect(version.class).to eq Version
      expect(version.user).to eq author
      expect(version.reason).to eq reason
      expect(version.item_diff).to eq result_diff
      expect(version.item).to eq anime
      expect(version.moderator).to be_nil
    end

    describe 'description change', :focus do
      let(:changes) {{ description: 'zzz', source: '7' }}

      it do
        expect(version).to be_persisted
        expect(version).to be_pending
        expect(version.class).to eq Versions::DescriptionVersion
      end
    end

    describe 'date change' do
      let(:anime) { create :anime, aired_on: '2007-03-02' }
      let(:changes) {{ 'aired_on(3i)' => '5', 'aired_on(2i)' => '4', 'aired_on(1i)' => '2008' }}

      it do
        expect(version).to be_persisted
        expect(version).to be_pending
        expect(version.item_diff).to eq 'aired_on' => ['2007-03-02', '2008-04-05']
      end
    end
  end

  describe '#postmoderate' do
    subject!(:version) { service.postmoderate changes, author, reason }

    it do
      expect(anime).to have_attributes changes
      expect(anime).to_not be_changed

      expect(version).to be_persisted
      expect(version).to be_auto_accepted
      expect(version.class).to eq Version
      expect(version.user).to eq author
      expect(version.reason).to eq reason
      expect(version.item_diff).to eq result_diff
      expect(version.item).to eq anime
      expect(version.moderator).to be_nil
    end
  end
end
