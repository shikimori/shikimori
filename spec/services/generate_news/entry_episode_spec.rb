describe GenerateNews::EntryEpisode do
  let(:anime) { build_stubbed :anime, episodes_aired: 5 }

  describe '#call' do
    let(:aired_at) { 1.month.ago }

    subject { GenerateNews::EntryEpisode.call anime, aired_at }

    context 'present news' do
      context 'same episode' do
        let!(:news) do
          create :news_topic,
            linked_id: anime.id,
            linked_type: Anime.name,
            action: AnimeHistoryAction::Episode,
            value: '5'
        end

        it { is_expected.to be_nil }
      end

      context 'prior episode' do
        let!(:news) do
          create :news_topic,
            linked_id: anime.id,
            linked_type: Anime.name,
            action: AnimeHistoryAction::Episode,
            value: '4'
        end

        it { is_expected.to be_persisted }
      end
    end

    context 'no news' do
      it do
        is_expected.to be_persisted
        is_expected.to have_attributes(
          linked_id: anime.id,
          linked_type: Anime.name,
          action: AnimeHistoryAction::Episode,
          value: '5',
          created_at: aired_at,
          generated: true
        )
      end
    end
  end
end
