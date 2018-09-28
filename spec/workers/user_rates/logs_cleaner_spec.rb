describe UserRates::LogsCleaner do
  subject { described_class.new.perform }

  let!(:user_rates_log_1) { create :user_rates_log, created_at: 15.days.ago }
  let!(:user_rates_log_2) { create :user_rates_log, created_at: 100.days.ago }
  let!(:user_rates_log_3) { create :user_rates_log, created_at: 13.days.ago }

  it do
    expect { subject }.to change(UserRatesLog, :count).by(-2)
    expect { user_rates_log_1.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { user_rates_log_2.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(user_rates_log_3.reload).to be_persisted
  end
end
