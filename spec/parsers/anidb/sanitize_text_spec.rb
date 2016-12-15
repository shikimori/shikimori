describe Anidb::SanitizeText do
  subject { described_class.new.(html) }

  describe '#bb_source' do
    context 'with source' do
      let(:html) { "Black Lagoon.\n\n<i>Source: AnimeNfo</i>" }
      it { is_expected.to eq 'Black Lagoon.[source]AnimeNfo[/source]' }
    end

    context 'without source' do
      let(:html) { "help to finally end Keiichi's unlucky days?" }
      it { is_expected.to eq "help to finally end Keiichi's unlucky days?" }
    end
  end
end
