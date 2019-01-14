describe Clubs::RestrictCensored do
  subject do
    described_class.call(
      club: club,
      current_user: current_user
    )
  end
  let(:club) { build :club, is_censored: is_censored }

  context 'censored' do
    let(:is_censored) { true }

    context 'guest' do
      let(:current_user) { nil }
      it { expect { subject }.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'not guest' do
      let(:current_user) { user_1 }
      it { is_expected.to be_nil }
    end
  end

  context 'not censored' do
    let(:is_censored) { false }
    let(:current_user) { [nil, user_1].sample }

    it { is_expected.to be_nil }
  end
end
