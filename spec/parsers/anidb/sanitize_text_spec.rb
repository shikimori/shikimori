describe Anidb::SanitizeText do
  subject { described_class.(html) }

  describe '#bb_source' do
    context 'with source in the end' do
      let(:html) { "foo\n\n<i>Source: AnimeNfo</i>" }
      it { is_expected.to eq 'foo[source]AnimeNfo[/source]' }
    end

    context 'with source in the middle' do
      let(:html) { "foo\n\n<i>Source: ANN</i>\n\nbar" }
      it { is_expected.to eq 'foo[source]ANN[/source]bar' }
    end

    context 'without source' do
      let(:html) { "help to finally end Keiichi's unlucky days?" }
      it { is_expected.to eq "help to finally end Keiichi's unlucky days?" }
    end
  end

  describe '#bb_link' do
    context 'character link' do
      let(:html) { 'foo <a href="https://anidb.net/ch2000">Nunnally</a> bar' }
      it { is_expected.to eq 'foo [Nunnally] bar' }
    end

    context 'creator link' do
      let(:html) { 'foo <a href="https://anidb.net/cr10211">Hiroe Rei</a> bar' }
      it { is_expected.to eq 'foo [Hiroe Rei] bar' }
    end

    context 'other links' do
      let(:html) { 'foo <a href="https://anidb.net/a8528">anime DVDs</a> bar' }
      it { is_expected.to eq 'foo anime DVDs bar' }
    end
  end
end
