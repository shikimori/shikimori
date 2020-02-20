describe LicensorsRepository do
  let(:query) { LicensorsRepository.instance }

  let!(:anime_1) { create :anime }
  let!(:anime_2) { create :anime, licensor: 'zxc' }
  let!(:anime_3) { create :anime, licensor: 'zxc' }
  let!(:anime_4) { create :anime, licensor: 'zxc' }
  let!(:anime_5) { create :anime, licensor: 'zxc' }
  let!(:anime_6) { create :anime, licensor: 'zxc' }
  let!(:anime_7) { create :anime, licensor: 'vbn' }

  let!(:manga_1) { create :manga, licensor: 'zxc' }
  let!(:manga_2) { create :manga, licensor: 'qwe' }

  let!(:ranobe_1) { create :ranobe, licensor: 'zxc' }

  it { expect(query.anime).to eq [%w[zxc], %w[vbn]] }
  it { expect(query.manga).to eq [%w[qwe zxc]] }
  it { expect(query.ranobe).to eq [%w[zxc]] }
end
