describe Profiles::ListStats do
  let(:list_stats) do
    Profiles::ListStats.new(
      id: 0,
      name: 'planned',
      type: 'Anime',
      grouped_id: '1,2',
      size: 10
    )
  end

  it { expect(list_stats.id).to eq 0 }
  it { expect(list_stats.localized_name).to eq 'Запланировано' }
  it { expect(list_stats.any?).to eq true }
end
