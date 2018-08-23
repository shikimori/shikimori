describe DbImport::BannedRoles do
  let(:service) { DbImport::BannedRoles.instance }

  describe '#banned?' do
    subject do
      service.banned?(
        anime_id: anime_id,
        manga_id: manga_id,
        character_id: character_id,
        person_id: person_id
      )
    end
    let(:anime_id) { 114 }
    let(:manga_id) { nil }
    let(:character_id) { 39691 }
    let(:person_id) { nil }

    it { is_expected.to eq true }

    context 'wrong id' do
      let(:character_id) { 9_999_999 }
      it { is_expected.to eq false }
    end
  end
end
