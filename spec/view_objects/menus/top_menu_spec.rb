describe Menus::TopMenu do
  let(:view) { Menus::TopMenu.new }

  describe '#anime_seasons' do
    before { Timecop.freeze '2015-10-11' }
    after { Timecop.return }

    it do
      expect(view.anime_seasons.first).to be_kind_of Titles::StatusTitle
      expect(view.anime_seasons.second).to be_kind_of Titles::SeasonTitle
      expect(view.anime_seasons.map(&:text)).to eq %w(
        ongoing
        2016 2015
        winter_2016 fall_2015 summer_2015 spring_2015
      )
    end
  end

  describe '#manga_kinds' do
    it do
      expect(view.manga_kinds.first).to be_kind_of Titles::KindTitle
      expect(view.manga_kinds.map(&:text)).to eq %w(
        manga manhwa manhua novel one_shot doujin
      )
    end
  end
end
