describe ClubPage::Update do
  subject { ClubPage::Update.call club_page, params, user }

  let(:club_page) { create :club_page, club: club }
  let(:club) { create :club }

  context 'valid params' do
    let(:params) do
      {
        name: 'uihbjb'
      }
    end

    it do
      is_expected.to eq true
      expect(club_page.errors).to be_empty
      expect(club_page.reload).to have_attributes params
    end
  end

  context 'invalid params' do
    let(:params) do
      {
        name: nil
      }
    end

    it do
      is_expected.to eq false
      expect(club_page.errors).to be_present
      expect(club_page.reload).not_to have_attributes params
    end
  end
end
