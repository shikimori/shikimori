describe Animes::StatusQuery do
  subject { described_class.call scope, status }
  let(:scope) { Anime.order(:id) }

  let!(:anons) { create :anime, :anons }
  let!(:ongoing) { create :anime, :ongoing }
  let!(:released_latest) { create :anime, :released, released_on: Animes::StatusQuery::LATEST_INTERVAL.ago + 1.day }
  let!(:released_old) { create :anime, :released, released_on: Animes::StatusQuery::LATEST_INTERVAL.ago - 1.day }

  context 'anons' do
    let(:status) { 'anons' }
    it { is_expected.to eq [anons] }
  end

  context 'ongoing' do
    let(:status) { 'ongoing' }
    it { is_expected.to eq [ongoing] }
  end

  context 'released' do
    let(:status) { 'released' }
    it { is_expected.to eq [released_latest, released_old] }
  end

  context 'latest' do
    let(:status) { 'latest' }
    it { is_expected.to eq [released_latest] }
  end

  context 'bad status' do
    let(:status) { :zzz }
    it { expect { subject }.to raise_error Dry::Types::ConstraintError }
  end
end
