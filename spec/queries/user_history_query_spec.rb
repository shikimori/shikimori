describe UserHistoryQuery do
  let(:user) { create :user }
  let(:query) { UserHistoryQuery.new user }

  let(:anime) { create :anime }
  let(:page) { 1 }
  let(:limit) { 1 }

  subject { query.postload page, limit }

  describe '#postload' do
    let!(:history) { create :user_history, user: user, target: anime }

    context 'one page' do
      its(:first) { should eq(today: [history]) }
      its(:second) { should be false }
    end

    context 'two pages' do
      let!(:history_2) { create :user_history, user: user, target: anime, updated_at: 2.days.ago }

      context 'first page' do
        its(:first) { should eq(today: [history]) }
        its(:second) { should be true }
      end

      context 'second page' do
        let(:page) { 2 }
        its(:first) { should eq(week: [history_2]) }
        its(:second) { should be false }
      end
    end
  end
end
