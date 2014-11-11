describe ClubsQuery do
  let(:query) { ClubsQuery.new }

  before { Timecop.freeze }
  let(:user) { create :user }
  let!(:club_1) { create :group, id: 1 }
  let!(:club_2) { create :group, id: 2 }
  let!(:club_3) { create :group, id: 3 }
  let!(:club_4) { create :group, id: 4 }

  before do
    club_1.members << user
    club_3.members << user
    club_4.members << user
  end

  describe :fetch do
    subject { query.fetch page, limit }
    let(:limit) { 2 }

    context :first_page do
      let(:page) { 1 }
      it { should eq [club_1, club_3, club_4] }
    end

    context :second_page do
      let(:page) { 2 }
      it { should eq [club_4] }
    end
  end

  describe :postload do
    subject { query.postload page, limit }
    let(:limit) { 2 }

    context :first_page do
      let(:page) { 1 }
      it { should eq [[club_1, club_3], true] }
    end

    context :second_page do
      let(:page) { 2 }
      it { should eq [[club_4], false] }
    end
  end
end
