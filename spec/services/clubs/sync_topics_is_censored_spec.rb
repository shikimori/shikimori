describe Clubs::SyncTopicsIsCensored do
  let(:entry) { create :club, is_censored: is_censored }
  let(:is_censored) { false }
  let!(:club_topic) do
    create :club_topic, linked: entry, is_censored: !is_censored
  end
  let(:club_page) { create :club_page, club: entry }
  let!(:club_page_topic) do
    create :club_page_topic, linked: club_page, is_censored: !is_censored
  end

  subject! { Clubs::SyncTopicsIsCensored.call entry }

  it do
    expect(club_topic.reload.is_censored).to eq is_censored
    expect(club_page_topic.reload.is_censored).to eq is_censored
  end
end
