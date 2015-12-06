describe Menus::CollectionMenu do
  include_context :view_object_warden_stub

  let(:user) { seed :user }
  let(:view) { Menus::CollectionMenu.new Anime }

  describe '#sorted_genres' do
    let!(:genre_1) { create :genre, position: 1, kind: :anime }
    let!(:genre_2) { create :genre, position: 2, kind: :anime }
    let!(:genre_3) { create :genre, position: 3, kind: :manga }

    it { expect(view.sorted_genres).to eq [genre_1, genre_2] }
  end

  describe '#statuses' do
    it do
      expect(view.statuses.first).to be_kind_of Titles::StatusTitle
      expect(view.statuses.map(&:text)).to eq %w(
        anons ongoing released latest
      )
    end
  end

  describe '#seasons' do
    before { Timecop.freeze '2015-10-11' }
    after { Timecop.return }

    it do
      expect(view.seasons.first).to be_kind_of Titles::SeasonTitle
      expect(view.seasons.map(&:text)).to eq %w(
        winter_2016 fall_2015 summer_2015 spring_2015
        2015 2014
        2012_2013 2007_2011 2000_2006
        199x 198x
        ancient
      )
    end
  end
end
