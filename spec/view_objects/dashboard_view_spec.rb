describe DashboardView do
  include_context :view_object_warden_stub
  let(:view) { DashboardView.new }

  describe '#ongoings' do
    let!(:anons) { create :anime, :anons }
    let!(:released) { create :anime, :released }
    let!(:ongoing_1) { create :anime, :ongoing, ranked: 10 }
    let!(:ongoing_2) { create :anime, :ongoing, ranked: 5 }

    it { expect(view.ongoings).to eq [ongoing_2, ongoing_1] }
  end

  describe '#seasons' do
    it { expect(view.seasons.last).to eq Menus::TopMenu.new.seasons.last }
    it { expect(view.seasons).to have(5).items }
  end

  describe '#reviews' do
    let!(:review) { create :review }
    it { expect(view.reviews).to have(1).item }
  end

  describe '#user_news' do
    let!(:anime_news) { create :anime_news, generated: false }
    it { expect(view.user_news).to have(1).item }
  end

  describe '#generated_news' do
    let!(:anime_news) { create :anime_news, generated: true }
    it { expect(view.generated_news).to have(1).item }
  end

  describe '#contests' do
    let!(:contest) { create :contest, :proposing }
    it { expect(view.contests).to have(1).item }
  end

  #describe 'favourites' do
    #let!(:user) { create :user, fav_animes: [anime_1] }
    #let!(:anime_1) { create :anime }
    #let!(:anime_2) { create :anime }

    #it { expect(view.favourites).to eq [anime_1] }
  #end
end
