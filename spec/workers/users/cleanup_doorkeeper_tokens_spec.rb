describe Users::CleanupDoorkeeperTokens do
  let!(:token_1) { create :oauth_token, revoked_at: 3.months.ago }
  let!(:token_2) { create :oauth_token, revoked_at: 5.months.ago }
  let!(:token_3) do
    create :oauth_token,
      created_at: 4.months.ago,
      expires_in: 1.week
  end
  let!(:token_4) do
    create :oauth_token,
      created_at: 5.months.ago,
      expires_in: 1.week
  end

  subject! { described_class.new.perform }

  it do
    expect(token_1.reload).to be_persisted
    expect { token_2.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(token_3.reload).to be_persisted
    expect { token_4.reload }.to raise_error ActiveRecord::RecordNotFound
  end
end
