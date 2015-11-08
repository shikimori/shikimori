describe Profiles::StatsBar do
  let(:lists_bar) { Profiles::StatsBar.new type: Anime.name, lists_stats: stats }
  let(:stats) { [completed_list, dropped_list, planned_list] }

  let(:completed_list) { Profiles::ListStats.new name: 'completed', size: 10 }
  let(:dropped_list) { Profiles::ListStats.new name: 'dropped', size: 5 }
  let(:planned_list) { Profiles::ListStats.new name: 'planned', size: 2 }

  it { expect(lists_bar.any?).to eq true }

  it { expect(lists_bar.total).to eq 17 }
  it { expect(lists_bar.completed).to eq 10 }
  it { expect(lists_bar.dropped).to eq 5 }
  it { expect(lists_bar.incompleted).to eq 2 }

  it { expect(lists_bar.completed_percent).to eq 58.82 }
  it { expect(lists_bar.dropped_percent).to eq 29.41 }
  it { expect(lists_bar.incompleted_percent).to eq 11.76 }
end
