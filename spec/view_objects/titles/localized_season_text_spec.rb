describe Titles::LocalizedSeasonText do
  let(:season_title) { Titles::LocalizedSeasonText.new klass, season_text }

  describe '#title' do
    subject { season_title.title }
    let(:klass) { Anime }

    context 'ongoing' do
      let(:season_text) { 'ongoing' }
      it { is_expected.to eq 'онгоинги' }
    end

    context 'latest' do
      let(:season_text) { 'latest' }
      it { is_expected.to eq 'последние аниме' }
    end

    context 'planned' do
      let(:season_text) { 'planned' }
      it { is_expected.to eq 'анонсы' }
    end

    context 'ancient' do
      let(:season_text) { 'ancient' }
      it { is_expected.to eq 'древности' }
    end

    context 'winter_2014' do
      let(:season_text) { 'winter_2014' }
      it { is_expected.to eq 'зимы 2014' }
    end

    context '1995' do
      let(:season_text) { '1995' }
      it { is_expected.to eq '1995 года' }
    end

    context '1995-2005' do
      let(:season_text) { '1995_2005' }
      it { is_expected.to eq '1995-2005 годов' }
    end

    context '199x' do
      let(:season_text) { '199x' }
      it { is_expected.to eq '90-х годов' }
    end
  end
end
