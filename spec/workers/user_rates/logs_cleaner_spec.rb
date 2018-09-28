describe UserRates::LogsCleaner do
  subject { described_class.new.perform }

  let!(:user_rate_log_1) { create :user_rate_log, created_at: 15.days.ago }
  let!(:user_rate_log_2) { create :user_rate_log, created_at: 100.days.ago }
  let!(:user_rate_log_3) { create :user_rate_log, created_at: 13.days.ago }

  it do
    expect { subject }.to change(UserRateLog, :count).by(-2)
    expect { user_rate_log_1.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { user_rate_log_2.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(user_rate_log_3.reload).to be_persisted
  end
end
