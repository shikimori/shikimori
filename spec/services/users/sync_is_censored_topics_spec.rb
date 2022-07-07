describe Users::SyncIsCensoredTopics do
  let(:user) { create :user }
  subject! { Users::SyncIsCensoredTopics.call user }

  context 'censored topics hidden' do
    it { expect(user.reload.preferences.is_censored_topics).to eq false }

    context 'change birthday to age above 18' do
      before { user.update birth_on: Time.zone.today - 18.years }
      it { expect(user.reload.preferences.is_censored_topics).to eq false }
    end

    context 'change birthday to age below 18' do
      before { user.update birth_on: Time.zone.today - 10.years }
      it { expect(user.reload.preferences.is_censored_topics).to eq false }
    end
  end

  context 'censored topics shown' do
    before { user.preferences.update is_censored_topics: true }

    context 'change birthday to age above 18' do
      before { user.update birth_on: Time.zone.today - 18.years }
      it { expect(user.reload.preferences.is_censored_topics).to eq true }
    end

    context 'change birthday to age below 18' do
      before { user.update birth_on: Time.zone.today - 10.years }
      it { expect(user.reload.preferences.is_censored_topics).to eq false }
    end
  end
end
