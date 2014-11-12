describe SiteStatistics do
  subject(:query) { SiteStatistics.new }

  describe 'cached_stats' do
    describe 'traffic' do
      let(:traffic) { 'traff' }
      before { allow_any_instance_of(YandexMetrika).to receive(:traffic_for_months).with(SiteStatistics::METRIKA_MONTHS).and_return traffic }

      its(:traffic) { should eq traffic }
    end

    describe 'comments' do
      let(:user) { create :user }
      let!(:comments) { create_list :comment, 1, user: user, commentable: create(:topic, user: user) }


      its(:comments) 'has at least 180 items' do
        expect(subject.size).to be >= 180
      end
      its(:comments_count) { should eq comments.last.id }
    end

    describe 'users' do
      let!(:users) { create_list :user, 2, created_at: Time.zone.yesterday + 8.hours }

      its(:users_count) { should eq users.last.id }

      its(:users) 'has at least 180 items' do
        expect(subject.size).to be >= 180
      end
      it { expect(query.users.last).to eq(date: Time.zone.yesterday.to_s, count: 2) }
    end
  end
end
