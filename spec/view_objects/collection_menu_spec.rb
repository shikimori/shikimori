describe CollectionMenu do
  let(:menu) { CollectionMenu.new Anime }
  before { menu.h.controller.request.env['warden'] ||= WardenStub.new }

  describe '#sorted_genres' do
    let!(:genre_1) { create :genre, position: 1, kind: :anime }
    let!(:genre_2) { create :genre, position: 2, kind: :anime }
    let!(:genre_3) { create :genre, position: 3, kind: :manga }

    it { expect(menu.sorted_genres).to eq [genre_1, genre_2] }
  end

  describe '#seasons',:focus do
    subject { menu.seasons }

    it do
      is_expected.to eq(
        'winter_2016' => 'Зима 2016',
        'fall_2015' => 'Осень 2015',
        'summer_2015' => 'Лето 2015',
        'spring_2015' => 'Весна 2015',
        '2015' => '2015 год',
        '2014' => '2014 год',
        '2012_2013' => '2012-2013',
        '2007_2011' => '2007-2011',
        '2000_2006' => '2000-2006',
        '199x' => '90е годы',
        '198x' => '80е годы',
        'ancient' => 'более старые'
      )
    end
  end
end
