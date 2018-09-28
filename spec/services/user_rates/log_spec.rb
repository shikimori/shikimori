describe UserRates::Log do
  subject do
    described_class.call(
      user_rate: user_rate,
      ip: ip,
      user_agent: user_agent,
      oauth_application_id: oauth_application_id
    )
  end

  let(:user_rate) { build_stubbed :user_rate }
  let(:ip) { '127.0.0.1' }
  let(:user_agent) { 'chrome' }
  let(:oauth_application_id) { [oauth_application.id, nil].sample }

  let(:oauth_application) { build_stubbed :oauth_application }

  it do
    expect { subject }.to change(UserRateLog, :count).by 1
    expect(subject.ip.to_s).to eq ip
    is_expected.to have_attributes(
      user: user_rate.user,
      target: user_rate.target,
      diff: {},
      user_agent: user_agent,
      oauth_application_id: oauth_application_id
    )
  end

  context 'create' do
    let(:user_rate) { create :user_rate }

    it do
      expect(subject.diff).to eq(
        'id' => [nil, user_rate.id]
      )
    end
  end

  context 'update' do
    let(:user_rate) { create :user_rate }
    before { user_rate.update score: 5 }

    it do
      expect(subject.diff).to eq(
        'score' => [0, 5]
      )
    end
  end

  context 'destroy' do
    let(:user_rate) { create :user_rate }
    before { user_rate.destroy! }

    it do
      expect(subject.diff).to eq(
        'id' => [user_rate.id, nil]
      )
    end
  end
end
