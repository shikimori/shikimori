describe DashboardView do
  let(:view) { DashboardView.new }

  describe '#ongoings' do
    let!(:anons) { create :anime, :anons }
    let!(:released) { create :anime, :released }
    let!(:ongoing_1) { create :anime, :ongoing, ranked: 10 }
    let!(:ongoing_2) { create :anime, :ongoing, ranked: 5 }

    it { expect(view.ongoings).to eq [ongoing_2, ongoing_1] }
  end

  describe 'favourites' do
    let!(:user) { create :user, fav_animes: [anime_1] }
    let!(:anime_1) { create :anime }
    let!(:anime_2) { create :anime }

    it { expect(view.favourites).to eq [anime_1] }
  end
end
