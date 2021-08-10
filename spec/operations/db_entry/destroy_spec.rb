describe DbEntry::Destroy do
  include_context :timecop
  let(:type) { %i[anime manga ranobe].sample }

  let!(:db_entry) { create type }
  let!(:user_rate) { create :user_rate, target: db_entry }
  let!(:user_rate_log) { create :user_rate_log, target: db_entry }
  let!(:user_history) { create :user_history, target: db_entry }

  subject! { described_class.call db_entry }

  it do
    expect { db_entry.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { user_rate.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { user_rate_log.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { user_history.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(user.rate_at).to eq Time.zone.now
  end
end
