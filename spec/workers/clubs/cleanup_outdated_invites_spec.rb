describe Clubs::CleanupOutdatedInvites do
  let!(:club_invite_1) do
    create :club_invite,
      created_at: described_class::OUTDATE_INTERVAL.ago - 1.day
  end
  let!(:club_invite_2) do
    create :club_invite,
      created_at: described_class::OUTDATE_INTERVAL.ago + 1.day
  end

  subject! { described_class.new.perform }

  it do
    expect { club_invite_1.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(club_invite_2.reload).to be_persisted
  end
end
