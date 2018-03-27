describe Animes::UpdateFranchises do
  subject(:perform) { Animes::UpdateFranchises.new.perform }

  context 'no chronology' do
    let!(:anime) { create :anime, name: 'test: qweyt', franchise: 'zxc' }
    before { perform }
    it { expect(anime.reload.franchise).to be_nil }
  end

  # context 'no franchise' do
  #   let!(:anime_1) { create :anime, name: 'test: qweyt' }
  #   let!(:anime_2) { create :anime, name: 'test fo' }
  #   let!(:anime_3) { create :anime, name: 'fofofo' }
  #   let!(:anime_4) { create :anime, franchise: 'zxc' }

  #   let!(:relation_12) { create :related_anime, source: anime_1, anime: anime_2 }
  #   let!(:relation_21) { create :related_anime, source: anime_2, anime: anime_1 }
  #   let!(:relation_23) { create :related_anime, source: anime_2, anime: anime_3 }
  #   let!(:relation_32) { create :related_anime, source: anime_3, anime: anime_2 }

  #   it do
  #     # expect(anime_1.reload.franchise).to eq 'test'
  #     # expect(anime_2.reload.franchise).to eq 'test'
  #     # expect(anime_3.reload.franchise).to eq 'test'
  #     expect(anime_4.reload.franchise).to be_nil
  #   end
  # end
end
