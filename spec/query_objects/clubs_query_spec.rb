describe ClubsQuery do
  let(:query) { ClubsQuery.new }

  before { Timecop.freeze }
  after { Timecop.return }

  let(:user) { create :user }
  let!(:club_1) { create :club, :with_topic, id: 1 }
  let!(:club_2) { create :club, :with_topic, id: 2 }
  let!(:club_3) { create :club, :with_topic, id: 3 }
  let!(:club_4) { create :club, :with_topic, id: 4 }
  let!(:club_favoured) { create :club, :with_topic, id: ClubsQuery::FAVOURITE.first }

  before do
    club_1.members << user
    club_3.members << user
    club_4.members << user
  end

  describe '#fetch' do
    subject { query.fetch page, limit }
    let(:limit) { 2 }

    context 'first_page' do
      let(:page) { 1 }
      it { is_expected.to eq [club_1, club_3, club_4] }
    end

    context 'second_page' do
      let(:page) { 2 }
      it { is_expected.to eq [club_4] }
    end
  end

  describe '#favourite' do
    subject { query.favourite }
    it { is_expected.to eq [club_favoured] }
  end

  describe '#postload' do
    subject { query.postload page, limit }
    let(:limit) { 2 }

    context 'first_page' do
      let(:page) { 1 }
      it { is_expected.to eq [[club_1, club_3], true] }
    end

    context 'second_page' do
      let(:page) { 2 }
      it { is_expected.to eq [[club_4], false] }
    end
  end
end
