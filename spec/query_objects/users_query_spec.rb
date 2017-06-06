describe UsersQuery do
  describe '#complete' do
    let!(:user_1) { create :user, nickname: 'ffff' }
    let!(:user_2) { create :user, nickname: 'testt' }
    let!(:user_3) { create :user, nickname: 'zula zula' }
    let!(:user_4) { create :user, nickname: 'test' }

    subject { UsersQuery.new(search: phrase).complete  }

    describe 'test' do
      let(:phrase) { 'test' }
      it { is_expected.to eq [user_2, user_4] }
    end

    describe 'z' do
      let(:phrase) { 'z' }
      it { is_expected.to eq [user_3] }
    end

    describe 'fofo' do
      let(:phrase) { 'fofo' }
      it { is_expected.to be_empty }
    end
  end

  describe '#search' do
    let!(:user_1) { create :user, nickname: 'ffff' }
    let!(:user_2) { create :user, nickname: 'testt' }
    let!(:user_3) { create :user, nickname: 'zula zula' }
    let!(:user_4) { create :user, nickname: 'test' }

    subject { UsersQuery.new(search: phrase).search  }

    describe 'test' do
      let(:phrase) { 'test' }
      it { is_expected.to eq [user_4, user_2] }
    end

    describe 'z' do
      let(:phrase) { 'z' }
      it { is_expected.to eq [user_3] }
    end

    describe 'fofo' do
      let(:phrase) { 'fofo' }
      it { is_expected.to be_empty }
    end
  end
end
