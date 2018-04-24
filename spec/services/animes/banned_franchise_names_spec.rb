describe Animes::BannedFranchiseNames do
  subject { described_class.instance }

  it { expect(subject.first).to eq 'dr' }
  it { is_expected.to have_at_least(2).items }
end
