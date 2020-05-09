describe DbEntry::Destroy do
  let!(:anime) { create :anime }
  let!(:user_rate) { create :user_rate, target: anime }
  let!(:user_rate_log) { create :user_rate_log, target: anime }
  let!(:user_history) { create :user_history, target: anime }

  subject! { described_class.call anime }

  it do
    expect { anime.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { user_rate.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { user_rate_log.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { user_history.reload }.to raise_error ActiveRecord::RecordNotFound
  end
end
