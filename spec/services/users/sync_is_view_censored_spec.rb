describe Users::SyncIsViewCensored do
  let(:user) { create :user, birth_on: birth_on, preferences: preferences }
  let(:preferences) { create :user_preferences, is_view_censored: is_view_censored }

  subject! { Users::SyncIsViewCensored.call user }

  context 'censored topics shown' do
    let(:is_view_censored) { true }

    context 'change birthday to age above 18' do
      let(:birth_on) { Time.zone.today - 18.years }
      it { expect(preferences.reload.is_view_censored).to eq true }
    end

    context 'change birthday to age below 18' do
      let(:birth_on) { Time.zone.today - 10.years }
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
      let(:birth_on) { Time.zone.today - 18.years }
      it { expect(preferences.reload.is_view_censored).to eq false }
    end

    context 'change birthday to age below 18' do
      let(:birth_on) { Time.zone.today - 10.years }
      it { expect(preferences.reload.is_view_censored).to eq false }
    end

    context 'change birthday nil' do
      let(:birth_on) { nil }
      it { expect(preferences.reload.is_view_censored).to eq false }
    end
  end
end
