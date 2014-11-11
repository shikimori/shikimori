describe SiteStatistics do
  subject(:query) { SiteStatistics.new }

  describe :cached_stats do
    describe :traffic do
      let(:traffic) { 'traff' }
      before { YandexMetrika.any_instance.stub(:traffic_for_months).with(SiteStatistics::METRIKA_MONTHS).and_return traffic }

      its(:traffic) { should eq traffic }
    end

    describe :comments do
      let(:user) { create :user }
      let!(:comments) { create_list :comment, 1, user: user, commentable: create(:topic, user: user) }

      its(:comments) { should have_at_least(180).items }
      its(:comments_count) { should eq comments.last.id }
    end

    describe :users do
      let!(:users) { create_list :user, 2, created_at: Time.zone.yesterday + 8.hours }

      its(:users_count) { should eq users.last.id }
      its(:users) { should have_at_least(180).items }
      it { expect(query.users.last).to eq(date: Time.zone.yesterday.to_s, count: 2) }
    end
  end
end
