describe NameValidator, type: :validator do
  let(:club) { build :club }
  let(:user) { build :user }

  context 'valid' do
    it { expect(club).to allow_value('test').for :name }
  end

  context 'invalid' do
    context 'club' do
      let!(:another_club) { create :club, name: 'test' }
      it do
        expect(club).to_not allow_value('test').for :name
        expect(club).to_not allow_value('Test').for :name
        expect(club).to_not allow_value('Tést').for :name
        expect(club).to_not allow_value('Tеst').for :name
        expect(club).to_not allow_value('Теst').for :name
      end
    end

    context 'user' do
      let!(:another_user) { create :user, nickname: 'test' }
      it do
        expect(user).to_not allow_value('test').for :nickname
        expect(user).to_not allow_value('Test').for :nickname
        expect(user).to_not allow_value('Tést').for :nickname
        expect(user).to_not allow_value('Tеst').for :nickname
        expect(user).to_not allow_value('Теst').for :nickname
      end
    end

    context 'abusive' do
      it do
        expect(club).to_not allow_value('хуй').for :name
        expect(club).to_not allow_value('бля').for :name
      end
    end

    context 'routing' do
      it do
        expect(club).to_not allow_value('.php').for :name
        expect(club).to_not allow_value('forum').for :name
        expect(club).to_not allow_value('clubs').for :name
        expect(club).to_not allow_value('animes').for :name
        expect(club).to_not allow_value('mangas').for :name
        expect(club).to_not allow_value('reviews').for :name
        expect(club).to_not allow_value('contests').for :name
      end
    end

    describe 'message' do
      let(:message) { club.errors.messages[:name].first }

      context 'taken' do
        let(:club) { build :club, name: 'test' }
        let!(:another_club) { create :club, name: 'test' }
        before { club.validate }

        it { expect(message).to eq I18n.t('activerecord.errors.messages.taken') }
      end

      context 'abusive' do
        let(:club) { build :club, name: 'хуй' }
        before { club.validate }

        it { expect(message).to eq I18n.t('activerecord.errors.messages.abusive') }
      end
    end
  end
end
