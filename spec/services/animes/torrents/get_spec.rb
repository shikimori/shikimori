describe Animes::Torrents::Get do
  subject { described_class.call anime }

  let(:anime) { build_stubbed :anime }

  context 'has torrents' do
    let!(:cache_entry) do
      create :pg_cache_data,
        key: "anime_#{anime.id}_torrents",
        value: 'zxc'
    end

    it { is_expected.to eq cache_entry.value }
  end

  context 'no torrents' do
    it { is_expected.to eq [] }
  end
end
