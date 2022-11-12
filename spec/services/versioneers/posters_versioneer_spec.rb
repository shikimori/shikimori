describe Versioneers::PostersVersioneer do
  let(:service) { described_class.new anime }
  let(:anime) { create :anime }
  let(:poster) do
    attributes_for(:poster, :image_data_uri)[:image_data_uri]
  end
  let(:author) { build_stubbed :user, role }
  let(:role) { :user }
  let(:reason) { 'change reason' }

  describe '#premoderate' do
    subject(:version) { service.premoderate poster, author, reason }

    it do
      expect { subject }.to change(Poster, :count).by(1)

      expect(version).to be_persisted
      expect(version).to be_pending
      expect(version).to be_instance_of Versions::PosterVersion
      expect(version).to have_attributes(
        user: author,
        reason: reason,
        item_diff: { 'action' => 'upload' },
        associated: anime,
        moderator: nil
      )
      expect(version.item).to be_kind_of Poster
      expect(version.item).to be_persisted
      expect(version.item).to have_attributes(
        anime_id: anime.id,
        manga_id: nil,
        character_id: nil,
        person_id: nil,
        is_approved: false
      )
    end
  end
end
