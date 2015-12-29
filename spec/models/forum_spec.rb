describe Forum do
  describe 'relations' do
    it { is_expected.to have_many :topics }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :permalink }
  end

  describe 'instance methods' do
    let!(:default_locale) { I18n.locale }
    after { I18n.locale = default_locale }

    describe '#name' do
      subject { forum.name }
      let(:forum) { build :forum }

      context 'ru' do
        before { I18n.locale = :ru }
        it { is_expected.to match /форум/ }
      end

      context 'en' do
        before { I18n.locale = :en }
        it { is_expected.to match /forum/ }
      end
    end
  end
end
