describe Profiles::ListStatsView do
  let(:profile_stats) do
    Users::ListStats.new(
      spent_time: spent_time,
      anime_spent_time: anime_spent_time,
      manga_spent_time: manga_spent_time,
      user: user,
      activity: {},
      anime_ratings: [],
      full_statuses: {},
      is_anime: true,
      is_manga: false,
      kinds: {},
      list_counts: {},
      scores: {},
      stats_bars: [],
      statuses: {},
      genres: {},
      studios: {},
      publishers: {}
    )
  end
  let(:user) { user_2 }
  let(:stats) { Profiles::ListStatsView.new(profile_stats) }

  let(:anime_spent_time) { SpentTime.new 0 }
  let(:manga_spent_time) { SpentTime.new 0 }
  let(:spent_time) { SpentTime.new 0 }

  describe '#spent_percent' do
    let(:spent_time) { SpentTime.new interval }
    subject { stats.spent_time_percent }

    context 'none' do
      let(:interval) { 0 }
      it { is_expected.to be_zero }
    end

    context 'week' do
      let(:interval) { 7 }
      it { is_expected.to eq 10 }
    end

    context '18.5 days' do
      let(:interval) { 18.5 }
      it { is_expected.to eq 20 }
    end

    context 'month' do
      let(:interval) { 30 }
      it { is_expected.to eq 30 }
    end

    context '2 months' do
      let(:interval) { 2 * 30 }
      it { is_expected.to eq 40 }
    end

    context '3 months' do
      let(:interval) { 3 * 30 }
      it { is_expected.to eq 50 }
    end

    context '4.5 months' do
      let(:interval) { 4.5 * 30 }
      it { is_expected.to eq 60 }
    end

    context '6 months' do
      let(:interval) { 6 * 30 }
      it { is_expected.to eq 70 }
    end

    context '9 months' do
      let(:interval) { 9 * 30 }
      it { is_expected.to eq 80 }
    end

    context 'year' do
      let(:interval) { 365 }
      it { is_expected.to eq 90 }
    end

    context '1.25 years' do
      let(:interval) { 365 * 1.25 }
      it { is_expected.to eq 95 }
    end

    context '1.5 years' do
      let(:interval) { 365 * 2 }
      it { is_expected.to eq 100 }
    end
  end

  describe '#spent_time_in_words' do
    let(:spent_time) { SpentTime.new interval }
    subject { stats.spent_time_in_words }

    context 'none' do
      let(:interval) { 0 }
      it { is_expected.to eq '0 часов' }
    end

    context '30 minutes' do
      let(:interval) { 1 / 24.0 / 2 }
      it { is_expected.to eq '30 минут' }
    end

    context '1 hour' do
      let(:interval) { 1 / 24.0 }
      it { is_expected.to eq '1 час' }
    end

    context '2.51 days' do
      let(:interval) { 2.5 }
      it { is_expected.to eq '2 дня и 12 часов' }
    end

    context '3 weeks' do
      let(:interval) { 21 }
      it { is_expected.to eq '3 недели' }
    end

    context '5.678 months' do
      let(:interval) { 5.678 * 30 }
      it { is_expected.to eq '5 месяцев и 2 недели' }
    end

    context '1.25 years' do
      let(:interval) { 365 * 1.25 }
      it { is_expected.to eq '1 год и 3 месяца' }
    end
  end

  describe '#spent_time_in_days' do
    let(:anime_spent_time) { SpentTime.new anime_interval }
    let(:manga_spent_time) { SpentTime.new manga_interval }
    let(:spent_time) { SpentTime.new(anime_interval + manga_interval) }

    let(:manga_interval) { 0 }
    subject { stats.spent_time_in_days }

    context 'none' do
      let(:anime_interval) { 0 }
      it { is_expected.to eq 'Всего 0 дней' }
    end

    context '30 minutes' do
      let(:anime_interval) { 1 / 24.0 / 2 }
      it { is_expected.to eq 'Всего 0 дней' }
    end

    context '1 hour' do
      let(:anime_interval) { 1 / 24.0 }
      it { is_expected.to eq 'Всего 0 дней' }
    end

    context '2.5 hours' do
      let(:anime_interval) { 1 / 24.0 * 2.5 }
      it { is_expected.to eq 'Всего 0.1 дней' }
    end

    context '2.5 days' do
      let(:anime_interval) { 1.5 }
      let(:manga_interval) { 1.1 }
      it { is_expected.to eq 'Всего 2.6 дней: 1.5 дней аниме и 1.1 дней манги' }
    end

    context '10.50 days' do
      let(:anime_interval) { 10.5 }
      it { is_expected.to eq '10 дней аниме' }
    end

    context '3 weeks' do
      let(:anime_interval) { 0 }
      let(:manga_interval) { 21 }
      it { is_expected.to eq '21 день манги' }
    end

    context '1.25 years' do
      let(:anime_interval) { 365 * 1.25 }
      it { is_expected.to eq '456 дней аниме' }
    end
  end
end
