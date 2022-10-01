describe Forum do
  describe 'relations' do
    it { is_expected.to have_many :topics }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :permalink }
  end

  describe 'instance methods' do
    describe '#name' do
      subject { forum.name }
      let(:forum) { build :forum }

      context 'ru' do
        it { is_expected.to match(/форум/) }
      end
    end
  end
end
