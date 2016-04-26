describe UserRates::Tracker do
  let(:tracker) { UserRates::Tracker.instance }
  let(:anime) { build_stubbed :anime }

  before { tracker.send :cleanup }
  after { tracker.send :cleanup }

  describe '#placeholder' do
    subject { tracker.placeholder anime }

    context 'anime' do
      let(:anime) { build_stubbed :anime, id: 123 }
      it { is_expected.to eq 'anime-123' }
    end

    context 'manga' do
      let(:anime) { build_stubbed :manga, id: 321 }
      it { is_expected.to eq 'manga-321' }
    end
  end

  describe '#sweep' do
    let(:html) do
      <<-HTML.strip
        <div data-track_user_rates="anime-1"></div>
        <div data-track_user_rates="manga-2"></div>
      HTML
    end
    before { tracker.send :track, 'anime-1' }
    subject! { tracker.sweep html }

    it { is_expected.to eq html }
    it { expect(tracker.send :cache).to eq ['anime-1', 'manga-2'] }
  end

  describe '#track, #anime_ids, #manga_ids' do
    before { tracker.send :track, 'anime-1' }
    before { tracker.send :track, 'anime-2' }
    before { tracker.send :track, 'manga-2' }

    it { expect(tracker.send :cache).to eq ['anime-1', 'anime-2', 'manga-2'] }
    it { expect(tracker.send :anime_ids).to eq [1, 2] }
    it { expect(tracker.send :manga_ids).to eq [2] }
    it { expect(Thread.current[UserRates::Tracker.name]).to eq ['anime-1', 'anime-2', 'manga-2'] }
  end

  describe '#cleanup' do
    before { tracker.send :track, anime }
    before { tracker.send :cleanup }

    it { expect(tracker.send :cache).to eq [] }
  end

  describe '#export' do
    before { tracker.send :track, "anime-#{anime_1.id}" }
    before { tracker.send :track, "anime-#{anime_2.id}" }
    before { tracker.export user_1 }

    let(:anime_1) { create :anime }
    let(:anime_2) { create :anime }
    let(:user_1) { seed :user }
    let(:user_2) { create :user }

    let!(:rate_1_1) { create :user_rate, target: anime_1, user: user_1 }
    let!(:rate_2_1) { create :user_rate, target: anime_2, user: user_1 }
    let!(:rate_1_2) { create :user_rate, target: anime_1, user: user_2 }

    it { expect(tracker.export user_1).to eq [rate_1_1, rate_2_1] }
    it { expect(tracker.export user_2).to eq [rate_1_2] }
  end
end
