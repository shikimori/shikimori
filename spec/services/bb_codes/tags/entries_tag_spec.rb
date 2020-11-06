describe BbCodes::Tags::EntriesTag do
  subject(:html) { described_class.instance.format text }

  describe 'type' do
    context 'animes' do
      let(:anime_1) { create :anime }
      let(:anime_2) { create :anime }
      let(:text) { "[animes ids=#{anime_1.id},#{anime_2.id}]\n" }

      it 'has default number of columns' do
        expect(html).to include "<div class='cc-#{BbCodes::Tags::EntriesTag::DEFAULT_COLUMNS}-g15 "
      end
      it('has entries') { expect(html.scan('b-catalog_entry')).to have(2).items }

      context 'max entries limit' do
        before { stub_const 'BbCodes::Tags::EntriesTag::MAX_ENTRIES', 2 }
        it('has entries') { expect(html.scan('b-catalog_entry')).to have(2).items }
      end

      context 'exact max entries limit' do
        before { stub_const 'BbCodes::Tags::EntriesTag::MAX_ENTRIES', 1 }
        it('has warn message') { expect(html).to eq '[color=red]limit exceeded (1 max)[/color]' }
      end
    end

    context 'mangas' do
      let(:manga) { create :manga }
      let(:text) { "[mangas ids=#{manga.id}]" }

      it { expect(html.scan('b-catalog_entry')).to have(1).items }
    end

    context 'ranobe' do
      let(:ranobe) { create :ranobe }
      let(:text) { "[ranobe ids=#{ranobe.id}]" }

      it { expect(html.scan('b-catalog_entry')).to have(1).items }
    end

    context 'characters' do
      let(:character) { create :character }
      let(:text) { "[characters ids=#{character.id}]" }

      it { expect(html.scan('b-catalog_entry')).to have(1).items }
    end

    context 'people' do
      let(:person) { create :person }
      let(:text) { "[people ids=#{person.id}]" }

      it { expect(html.scan('b-catalog_entry')).to have(1).items }
    end
  end

  describe 'columns' do
    let(:anime) { create :anime }
    let(:text) { "[animes ids=#{anime.id} columns=4]" }

    it { expect(html).to include "<div class='cc-4 " }
  end

  describe 'class' do
    let(:anime) { create :anime }
    let(:text) { "[animes ids=#{anime.id} class=zxc-vb_n]" }

    it { expect(html).to include "<div class='zxc-vb_n " }
  end

  describe 'cover_notice' do
    let(:anime) { create :anime, aired_on: Time.zone.parse('1987-01-01') }
    let(:text) { "[animes ids=#{anime.id} cover_notice=year_kind]" }

    it('has entry') { expect(html).to include 'b-catalog_entry' }
    it('has year') { expect(html).to include '1987' }
  end

  describe 'wall' do
    let(:anime) { create :anime, aired_on: Time.zone.parse('1987-01-01') }
    let(:text) { "[animes ids=#{anime.id} wall columns=8]" }

    it('has entry') { expect(html).to include 'b-catalog_entry' }
    it('has aligned posters') { expect(html).to include 'cc-8-g0 align-posters unprocessed' }
  end
end
