describe Users::SyncIsViewCensored do
  subject! { Users::SyncIsViewCensored.call user }

  let(:user) { create :user, birth_on:, preferences: }
  let(:preferences) { create :user_preferences, is_view_censored: }

  context 'censored topics shown' do
    let(:is_view_censored) { true }

    context 'change birthday to age above 18' do
      let(:birth_on) { 18.years.ago }
      it { expect(preferences.reload.is_view_censored).to eq true }
    end

    context 'change birthday to age below 18' do
      let(:birth_on) { 10.years.ago }
      it { expect(preferences.reload.is_view_censored).to eq false }
    end

    context 'change birthday nil' do
      let(:birth_on) { nil }
      it { expect(preferences.reload.is_view_censored).to eq false }
    end
  end

  context 'censored topics hidden' do
    let(:is_view_censored) { false }

    context 'change birthday to age above 18' do
      let(:birth_on) { 18.years.ago }
      it { expect(preferences.reload.is_view_censored).to eq false }
    end

    context 'change birthday to age below 18' do
      let(:birth_on) { 10.years.ago }
      it { expect(preferences.reload.is_view_censored).to eq false }
    end

    context 'change birthday nil' do
      let(:birth_on) { nil }
      it { expect(preferences.reload.is_view_censored).to eq false }
    end
  end
end
