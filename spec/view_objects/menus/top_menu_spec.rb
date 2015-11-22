describe Menus::TopMenu do
  let(:view) { Menus::TopMenu.new }

  describe '#seasons' do
    before { Timecop.freeze '2015-10-11' }
    after { Timecop.return }

    it do
      expect(view.seasons.first).to be_kind_of StatusTitle
      expect(view.seasons.second).to be_kind_of SeasonTitle
      expect(view.seasons.map(&:text)).to eq %w(
        ongoing
        2016 2015
        winter_2016 fall_2015 summer_2015 spring_2015
      )
    end
  end
end
