describe Users::GrantedApplications do
  subject { described_class.call user }

  let(:oauth_application_1) { create :oauth_application }
  let(:oauth_application_2) { create :oauth_application }
  let(:oauth_application_3) { create :oauth_application }

  let!(:oauth_grant_1) do
    create :oauth_grant,
      resource_owner_id: user.id,
      application: oauth_application_1
  end
  let!(:oauth_grant_1_2) do
    create :oauth_grant,
      resource_owner_id: user.id,
      application: oauth_application_1
  end
  let!(:oauth_grant_2) do
    create :oauth_grant,
      resource_owner_id: user.id,
      application: oauth_application_2
  end
  let!(:oauth_grant_3) do
    create :oauth_grant,
      resource_owner_id: build_stubbed(:user).id,
      application: oauth_application_3
  end

  it { is_expected.to eq [oauth_application_1, oauth_application_2] }
end
