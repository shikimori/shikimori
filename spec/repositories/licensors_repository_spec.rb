describe LicensorsRepository do
  let(:query) { described_class.instance }

  before { query.reset }

  let!(:anime_1) { create :anime }
  let!(:anime_2) { create :anime, licensors: %w[zxc] }
  let!(:anime_3) { create :anime, licensors: %w[zxc] }
  let!(:anime_4) { create :anime, licensors: %w[zxc] }
  let!(:anime_5) { create :anime, licensors: %w[zxc] }
  let!(:anime_6) { create :anime, licensors: %w[zxc vbn] }

  let!(:manga_1) { create :manga, licensors: %w[zxc qwe] }

  let!(:ranobe_1) { create :ranobe, licensors: %w[zxc] }

  it { expect(query.anime).to eq [%w[zxc], %w[vbn]] }
  it { expect(query.manga).to eq [%w[qwe zxc]] }
  it { expect(query.ranobe).to eq [%w[zxc]] }
end
