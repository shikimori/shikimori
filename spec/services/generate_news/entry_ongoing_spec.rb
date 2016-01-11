describe GenerateNews::EntryOngoing do
  let(:anime) { build_stubbed :anime }

  before { Timecop.freeze }
  after { Timecop.return }

  describe '#call' do
    subject { GenerateNews::EntryOngoing.call anime }

    it do
      is_expected.to be_persisted
      is_expected.to have_attributes(
        linked_id: anime.id,
        linked_type: Anime.name,
        action: AnimeHistoryAction::Ongoing,
        value: nil,
        created_at: Time.zone.now,
        generated: true,
        processed: false
      )
    end
  end
end
