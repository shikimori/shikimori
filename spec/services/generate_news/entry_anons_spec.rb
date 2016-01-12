describe GenerateNews::EntryAnons do
  let(:anime) { build_stubbed :anime }

  before { Timecop.freeze }
  after { Timecop.return }

  describe '#call' do
    subject { GenerateNews::EntryAnons.call anime }

    context 'present news' do
      let!(:news) do
        create :news_topic,
          linked_id: anime.id,
          linked_type: Anime.name,
          action: AnimeHistoryAction::Anons,
          value: nil
      end

      it { is_expected.to eq news }
    end

    context 'no news' do
      it do
        is_expected.to be_persisted
        is_expected.to have_attributes(
          linked_id: anime.id,
          linked_type: Anime.name,
          action: AnimeHistoryAction::Anons,
          value: nil,
          created_at: Time.zone.now,
          updated_at: nil,
          generated: true,
          processed: false
        )
      end
    end
  end
end
