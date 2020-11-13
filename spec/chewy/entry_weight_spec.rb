describe Relevance::EntryWeight do
  subject { described_class.call entry }
  let(:entry) do
    build :anime,
      kind: kind,
      score: score,
      aired_on: aired_on,
      is_censored: is_censored
  end

  let(:kind) { :tv }
  let(:score) { 10 }
  let(:aired_on) { Date.new year }
  let(:year) { Relevance::EntryWeight::OLD_YEAR }
  let(:is_censored) { false }

  it { is_expected.to eq 1.875 }

  context 'year' do
    let(:year) { Relevance::EntryWeight::OLD_YEAR - 1 }
    it { is_expected.to eq 1.699 }
  end

  context 'score' do
    let(:score) { 6 }
    it { is_expected.to eq 1.778 }
  end

  context 'kind' do
    let(:kind) { :special }
    it { is_expected.to eq 1.79 }
  end

  context 'censored' do
    let(:is_censored) { true }
    it { is_expected.to eq 1.438 }
  end

  context 'all bad factors' do
    let(:year) { Relevance::EntryWeight::OLD_YEAR - 1 }
    let(:score) { 6 }
    let(:kind) { :special }
    it { is_expected.to eq 1.703 }
  end
end
