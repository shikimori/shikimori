class NameValidatable < Club
  include ActiveModel::Validations
  validates :name, name: true
end

describe NameValidator, type: :validator do
  subject { NameValidatable.new name: 'test' }

  context 'valid' do
    it { is_expected.to allow_value('test').for :name }

    context 'own_name' do
      subject { NameValidatable.create! name: 'test', owner: build_stubbed(:user) }
      it { is_expected.to allow_value('test').for :name }
    end
  end

  context 'invalid' do
    context 'club' do
      let!(:club) { create :club, name: 'test' }

      it do
        is_expected.to_not allow_value('test').for :name
        is_expected.to_not allow_value('Test').for :name
        is_expected.to_not allow_value('Tést').for :name
        is_expected.to_not allow_value('Tеst').for :name
        is_expected.to_not allow_value('Теst').for :name
      end
    end

    context 'user' do
      let!(:club) { create :user, nickname: 'test' }

      it do
        is_expected.to_not allow_value('test').for :name
        is_expected.to_not allow_value('Test').for :name
        is_expected.to_not allow_value('Tést').for :name
        is_expected.to_not allow_value('Tеst').for :name
        is_expected.to_not allow_value('Теst').for :name
      end
    end

    context 'routing' do
      it do
        is_expected.to_not allow_value('clubs').for :name
        is_expected.to_not allow_value('animes').for :name
        is_expected.to_not allow_value('mangas').for :name
        is_expected.to_not allow_value('reviews').for :name
        is_expected.to_not allow_value('contests').for :name
      end

      describe 'message' do
        let!(:club) { create :user, nickname: 'test' }
        before { subject.valid? }

        let(:message) { subject.errors.messages[:name].first }
        it { expect(message).to eq I18n.t('activerecord.errors.messages.taken') }
      end
    end
  end
end
