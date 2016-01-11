describe GenerateNews::EntryAnons do
  let(:anime) { build_stubbed :anime, released_on: released_on }

  before { Timecop.freeze }
  after { Timecop.return }

  describe '#call' do
    subject { GenerateNews::EntryRelease.call anime }

    context 'no release' do
      let(:released_on) { nil }

      it do
        is_expected.to be_persisted
        is_expected.to have_attributes(
          linked_id: anime.id,
          linked_type: Anime.name,
          action: AnimeHistoryAction::Released,
          value: nil,
          created_at: Time.zone.now,
          generated: true,
          processed: false
        )
      end
    end

    context 'new release' do
      let(:released_on) { 13.days.ago }
      it do
        is_expected.to have_attributes(
          processed: false,
          created_at: Time.zone.now
        )
      end
    end

    context 'old release' do
      let(:released_on) { 15.days.ago }
      it do
        is_expected.to have_attributes(
          processed: true,
          created_at: anime.released_on.to_datetime
        )
      end
    end
  end
end
