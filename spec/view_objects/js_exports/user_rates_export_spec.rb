describe JsExports::UserRatesExport do
  let(:tracker) { described_class.instance }

  before { tracker.send :cleanup }
  after { tracker.send :cleanup }

  describe '#placeholder' do
    subject { tracker.placeholder :catalog_entry, entry }

    context 'anime' do
      let(:entry) { build_stubbed :anime, id: 123 }
      it { is_expected.to eq 'catalog_entry:anime:123' }
    end

    context 'manga' do
      let(:entry) { build_stubbed :manga, id: 321 }
      it { is_expected.to eq 'catalog_entry:manga:321' }
    end
  end

  describe '#sweep' do
    let(:html) do
      <<-HTML.strip
        <div data-track_user_rate="catalog_entry:anime:1"></div>
        <div data-track_user_rate="catalog_entry:manga:2"></div>
      HTML
    end
    before { tracker.send :track, :catalog_entry, :anime, 3 }
    subject! { tracker.sweep html }

    it do
      is_expected.to eq html
      expect(tracker.send :cache).to eq(
        catalog_entry: { anime: [1], manga: [2] },
        user_rate: { anime: [], manga: [] }
      )
    end
  end

  describe '#export' do
    before do
      tracker.send :track, :catalog_entry, :anime, anime_1.id
      tracker.send :track, :catalog_entry, :anime, anime_2.id
      tracker.export user_1, Ability.new(user_1)
    end

    let(:anime_1) { create :anime }
    let(:anime_2) { create :anime }
    let(:user_1) { seed :user }
    let(:user_2) { create :user }

    let!(:rate_1_1) { create :user_rate, target: anime_1, user: user_1 }
    let!(:rate_2_1) { create :user_rate, target: anime_2, user: user_1 }
    let!(:rate_1_2) { create :user_rate, target: anime_1, user: user_2 }

    let(:export_1) { tracker.export user_1, Ability.new(user_1) }
    let(:export_2) { tracker.export user_2, Ability.new(user_2) }

    it do
      expect(export_1).to have(2).items
      expect(export_1[:catalog_entry].first).to be_kind_of UserRateSerializer
      expect(export_1[:catalog_entry].map(&:object)).to eq [rate_1_1, rate_2_1]
      expect(export_1[:user_rate]).to eq []

      expect(export_2).to have(2).items
      expect(export_2[:catalog_entry].map(&:object)).to eq [rate_1_2]
      expect(export_2[:user_rate]).to eq []
    end
  end
end
