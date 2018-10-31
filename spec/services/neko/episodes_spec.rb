describe Neko::Episodes do
  subject { described_class.call anime }

  let(:anime) do
    build :anime,
      status,
      episodes: episodes,
      episodes_aired: episodes_aired
  end
  let(:status) { :released }
  let(:episodes) { 10 }
  let(:episodes_aired) { 10 }

  context 'anons' do
    let(:status) { :anons }
    it { is_expected.to eq 0 }
  end

  context 'ongoing' do
    let(:status) { :ongoing }

    context 'episodes_aired > 0' do
      let(:episodes_aired) { 9 }
      it { is_expected.to eq 9 }
    end

    context 'episodes_aired == 0' do
      let(:episodes_aired) { 0 }
      it { is_expected.to eq 10 }
    end
  end

  context 'released', :focus do
    let(:episodes_aired) { 999 }
    it { is_expected.to eq 10 }
  end
end
