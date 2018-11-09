describe Animes::FranchiseName do
  subject! { described_class.call animes, taken_names }

  let(:animes) { [anime_1, anime_2, anime_3] }
  let(:taken_names) { [] }

  let(:anime_1) { build_stubbed :anime, name: 'Test' }
  let(:anime_2) { build_stubbed :anime, name: 'Test fo' }
  let(:anime_3) { build_stubbed :anime, name: 'Test zxc' }

  it { is_expected.to eq 'test' }

  describe 'name cleanup' do
    context 'name with ":"' do
      let(:anime_1) { build_stubbed :anime, name: 'Test: qweyt' }
      it { is_expected.to eq 'test' }
    end

    context 'special symbols' do
      let(:anime_1) { build_stubbed :anime, name: 'Test_123/' }
      it { is_expected.to eq 'test_fo' }
    end

    context 'unicode symbols' do
      let(:anime_1) { build_stubbed :anime, name: 'Testá' }
      it { is_expected.to eq 'test' }
    end
  end

  context 'taken name' do
    let(:taken_names) { ['test'] }
    it { is_expected.to eq 'test_fo' }
  end

  context 'banned name' do
    let(:anime_1) { build_stubbed :anime, name: 'dr' }
    it { is_expected.to eq 'test_fo' }
  end

  describe 'keep old franchise name' do
    context 'less than half of entries with set franchise' do
      let(:anime_1) { build_stubbed :anime, name: 'Test', franchise: 'test_fo' }
      it { is_expected.to eq 'test' }
    end

    context 'more than half of entries with set franchise' do
      let(:anime_1) { build_stubbed :anime, name: 'Test', franchise: 'test_fo' }
      let(:anime_2) { build_stubbed :anime, name: 'Test fo', franchise: 'test_fo' }

      it { is_expected.to eq 'test_fo' }
    end

    context 'name does not exists among possible names' do
      let(:anime_1) { build_stubbed :anime, name: 'Test', franchise: 'zxc' }
      let(:anime_2) { build_stubbed :anime, name: 'Test fo', franchise: 'zxc' }
      let(:anime_3) { build_stubbed :anime, name: 'Test fo', franchise: 'zxc' }

      it { is_expected.to eq 'test' }
    end
  end
end
