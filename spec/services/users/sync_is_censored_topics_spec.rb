describe Users::SyncIsCensoredTopics do
  let(:user) { create :user, birth_on: birth_on, preferences: preferences }
  let(:preferences) { create :user_preferences, is_censored_topics: is_censored_topics }

  subject! { Users::SyncIsCensoredTopics.call user }

  context 'censored topics shown' do
    let(:is_censored_topics) { true }

    context 'change birthday to age above 18' do
      let(:birth_on) { Time.zone.today - 18.years }
      it { expect(preferences.reload.is_censored_topics).to eq true }
    end

    context 'change birthday to age below 18' do
      let(:birth_on) { Time.zone.today - 10.years }
      it { expect(preferences.reload.is_censored_topics).to eq false }
    end

    context 'change birthday nil' do
      let(:birth_on) { nil }
      it { expect(preferences.reload.is_censored_topics).to eq false }
    end
  end

  context 'censored topics hidden' do
    let(:is_censored_topics) { false }

    context 'change birthday to age above 18' do
      let(:birth_on) { Time.zone.today - 18.years }
      it { expect(preferences.reload.is_censored_topics).to eq false }
    end

    context 'change birthday to age below 18' do
      let(:birth_on) { Time.zone.today - 10.years }
      it { expect(preferences.reload.is_censored_topics).to eq false }
    end

    context 'change birthday nil' do
      let(:birth_on) { nil }
      it { expect(preferences.reload.is_censored_topics).to eq false }
    end
  end
end
