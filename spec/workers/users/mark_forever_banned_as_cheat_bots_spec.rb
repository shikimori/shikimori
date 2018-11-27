describe Users::MarkForeverBannedAsCheatBots do
  include_context :timecop

  let!(:user_1) do
    create :user,
      read_only_at: described_class::FOREVER_BAN_INTERVAL.from_now + 1.minute,
      last_online_at: described_class::ACTIVE_INTERVAL.ago - 1.minute
  end
  let!(:user_2) do
    create :user,
      read_only_at: described_class::FOREVER_BAN_INTERVAL.from_now - 1.minute,
      last_online_at: described_class::ACTIVE_INTERVAL.ago - 1.minute
  end
  let!(:user_3) do
    create :user,
      read_only_at: described_class::FOREVER_BAN_INTERVAL.from_now + 1.minute,
      last_online_at: described_class::ACTIVE_INTERVAL.ago + 1.minute
  end
  let!(:user_4) do
    create :user,
      read_only_at: described_class::FOREVER_BAN_INTERVAL.from_now + 1.minute,
      last_online_at: described_class::ACTIVE_INTERVAL.ago - 1.minute,
      roles: %i[cheat_bot]
  end

  before { user_4.update_column :updated_at, nil }

  subject! { described_class.new.perform }

  it do
    expect(User.find(user_1.id)).to be_cheat_bot
    expect(User.find(user_1.id).updated_at).to be_within(0.1).of Time.zone.now

    expect(User.find(user_2.id)).to_not be_cheat_bot
    expect(User.find(user_3.id)).to_not be_cheat_bot

    expect(user_4.reload.updated_at).to be_nil
  end
end
