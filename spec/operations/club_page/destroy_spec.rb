describe ClubPage::Destroy do
  subject { described_class.call club_page, user }
  let!(:club_page) { create :club_page, club: club }
  let(:club) { create :club }

  it do
    expect { subject }.to change(ClubPage, :count).by(-1)
    expect { club_page.reload }.to raise_error ActiveRecord::RecordNotFound
  end
end
