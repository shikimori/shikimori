describe BansQuery do
  let(:query) { BansQuery.new }

  let!(:ban_1) { create :ban, user: user, moderator: user, comment: create(:comment, user: user) }
  let!(:ban_2) { create :ban, user: user, moderator: user }
  let!(:ban_3) { create :ban, user: user, moderator: user }
  let!(:ban_4) { create :ban, user: user, moderator: user }

  describe '#fetch' do
    subject { query.fetch page, limit }
    let(:limit) { 2 }

    context 'first_page' do
      let(:page) { 1 }
      it { should eq [ban_4, ban_3, ban_2] }
    end

    context 'second_page' do
      let(:page) { 2 }
      it { should eq [ban_2, ban_1] }
    end
  end

  describe '#postload' do
    subject { query.postload page, limit }
    let(:limit) { 2 }

    context 'first_page' do
      let(:page) { 1 }
      it { should eq [[ban_4, ban_3], true] }
    end

    context 'second_page' do
      let(:page) { 2 }
      it { should eq [[ban_2, ban_1], false] }
    end
  end
end
