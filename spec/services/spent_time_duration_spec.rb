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
    let(:user_rate) do
      build :user_rate,
        rewatches: rewatches,
        chapters: read_chapters,
        volumes: read_volumes,
        manga: manga
    end
    let(:manga) { [build(:manga), build(:ranobe)].sample }

    let(:read_chapters) { 10 }
    let(:read_volumes) { 0 }

    let(:entry_chapters) { 70 }
    let(:entry_volumes) { 7 }

    let(:read_chapters_duration) { read_chapters * manga.class::CHAPTER_DURATION }
    let(:read_volumes_duration) { read_volumes * manga.class::VOLUME_DURATION }
    let(:full_chapters_duration) { entry_chapters * manga.class::CHAPTER_DURATION }
    let(:full_volumes_duration) { entry_volumes * manga.class::VOLUME_DURATION }

    subject { duration.manga_hours entry_chapters, entry_volumes }

    context 'chapters time >= volumes time' do
      context 'no rewatches' do
        let(:rewatches) { 0 }
        it { is_expected.to eq read_chapters_duration }
      end

      context '2 rewatches' do
        let(:rewatches) { 2 }

        context 'chapters rewatches > volumes rewatches' do
          it { is_expected.to eq full_chapters_duration * 2 + read_chapters_duration }
        end

        context 'chapters rewatches < volumes rewatches' do
          let(:entry_volumes) { 8 }
          it { is_expected.to eq full_volumes_duration * 2 + read_chapters_duration }
        end
      end

      context 'MAXIMUM_REWATCHES rewatches' do
        let(:rewatches) { SpentTimeDuration::MAXIMUM_REWATCHES }
        it { is_expected.to eq read_chapters_duration }
      end
    end

    context 'chapters time < volumes time' do
      let(:read_volumes) { 2 }

      context 'no rewatches' do
        let(:rewatches) { 0 }
        it { is_expected.to eq read_volumes_duration }
      end

      context '2 rewatches' do
        let(:rewatches) { 2 }

        context 'chapters rewatches > volumes rewatches' do
          it { is_expected.to eq full_chapters_duration * 2 + read_volumes_duration }
        end

        context 'chapters rewatches < volumes rewatches' do
          let(:entry_volumes) { 8 }
          it { is_expected.to eq full_volumes_duration * 2 + read_volumes_duration }
        end
      end

      context 'MAXIMUM_REWATCHES rewatches' do
        let(:rewatches) { SpentTimeDuration::MAXIMUM_REWATCHES }
        it { is_expected.to eq read_volumes_duration }
      end
    end
  end
end
