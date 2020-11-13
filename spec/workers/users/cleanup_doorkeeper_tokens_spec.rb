describe Users::CleanupDoorkeeperTokens do
  let(:oauth_application) { create :oauth_application }

  let!(:token_1) do
    create :oauth_token,
      application: oauth_application,
      revoked_at: 3.months.ago
  end
  let!(:token_2) do
    create :oauth_token,
      application: oauth_application,
      revoked_at: 5.months.ago
  end
  let!(:token_3) do
    create :oauth_token,
      application: oauth_application,
      created_at: 4.months.ago,
      expires_in: 1.week
  end
  let!(:token_4) do
    create :oauth_token,
      application: oauth_application,
      created_at: 5.months.ago,
      expires_in: 1.week
  end

  let!(:grant_1) do
    create :oauth_token,
      application: oauth_application,
      revoked_at: 3.months.ago
  end
  let!(:grant_2) do
    create :oauth_grant,
      application: oauth_application,
      created_at: 5.months.ago,
      expires_in: 1.week
  end

  subject! { described_class.new.perform }

  it do
    expect { token_1.reload }.to raise_error ActiveRecord::RecordNotFound
    expect { token_2.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(token_3.reload).to be_persisted
    expect { token_4.reload }.to raise_error ActiveRecord::RecordNotFound

    expect { grant_1.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(grant_2.reload).to be_persisted
  end
end
