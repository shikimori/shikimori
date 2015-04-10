describe SpentTimeDuration do
  let(:duration) { SpentTimeDuration.new user_rate }

  describe '#anime_hours' do
    let(:user_rate) { build :user_rate, rewatches: rewatches, episodes: watched_episodes }
    let(:watched_episodes) { 10 }
    let(:episode_duration) { 3 }
    let(:entry_episodes) { 7 }

    subject { duration.anime_hours entry_episodes, episode_duration }

    context 'no rewatches' do
      let(:rewatches) { 0 }
      it { is_expected.to eq 30 }
    end

    context '2 rewatches' do
      let(:rewatches) { 2 }
      it { is_expected.to eq 21 * 2 + 30 }
    end

    context 'MAXIMUM_REWATCHES rewatches' do
      let(:rewatches) { SpentTimeDuration::MAXIMUM_REWATCHES }
      it { is_expected.to eq 30 }
    end
  end

  describe '#manga_hours' do
    let(:user_rate) { build :user_rate, rewatches: rewatches, chapters: read_chapters, volumes: read_volumes }

    let(:read_chapters) { 10 }
    let(:read_volumes) { 0 }

    let(:entry_chapters) { 70 }
    let(:entry_volumes) { 7 }

    subject { duration.manga_hours entry_chapters, entry_volumes }

    context 'chapters time >= volumes time' do
      context 'no rewatches' do
        let(:rewatches) { 0 }
        it { is_expected.to eq 80 }
      end

      context '2 rewatches' do
        let(:rewatches) { 2 }

        context 'chapters rewatches > volumes rewatches' do
          it { is_expected.to eq 70 * Manga::CHAPTER_DURATION * 2 + 80 }
        end

        context 'chapters rewatches < volumes rewatches' do
        let(:entry_volumes) { 8 }
          it { is_expected.to eq 8 * Manga::VOLUME_DURATION * 2 + 80 }
        end
      end

      context 'MAXIMUM_REWATCHES rewatches' do
        let(:rewatches) { SpentTimeDuration::MAXIMUM_REWATCHES }
        it { is_expected.to eq 80 }
      end
    end

    context 'chapters time < volumes time' do
      let(:read_volumes) { 2 }

      context 'no rewatches' do
        let(:rewatches) { 0 }
        it { is_expected.to eq Manga::VOLUME_DURATION * read_volumes }
      end

      context '2 rewatches' do
        let(:rewatches) { 2 }

        context 'chapters rewatches > volumes rewatches' do
          it { is_expected.to eq 70 * Manga::CHAPTER_DURATION * 2 + Manga::VOLUME_DURATION * read_volumes }
        end

        context 'chapters rewatches < volumes rewatches' do
        let(:entry_volumes) { 8 }
          it { is_expected.to eq 8 * Manga::VOLUME_DURATION * 2 + Manga::VOLUME_DURATION * read_volumes }
        end
      end

      context 'MAXIMUM_REWATCHES rewatches' do
        let(:rewatches) { SpentTimeDuration::MAXIMUM_REWATCHES }
        it { is_expected.to eq Manga::VOLUME_DURATION * read_volumes }
      end
    end
  end
end
