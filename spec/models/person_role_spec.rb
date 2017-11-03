describe PersonRole do
  describe 'relations' do
    it { is_expected.to belong_to :anime }
    it { is_expected.to belong_to :manga }
    it { is_expected.to belong_to :character }
    it { is_expected.to belong_to :person }
  end

  describe 'instance methods' do
    describe '#entry' do
      let(:person_role) { build :person_role, anime: anime, manga: manga }
      subject { person_role.entry }

      context 'no anime, no manga' do
        let(:anime) { nil }
        let(:manga) { nil }
        it { is_expected.to be_nil }
      end

      context 'with anime' do
        let(:anime) { build :anime }
        let(:manga) { nil }
        it { is_expected.to eq anime }
      end

      context 'with manga' do
        let(:anime) { nil }
        let(:manga) { build :manga }
        it { is_expected.to eq manga }
      end
    end
  end
end
