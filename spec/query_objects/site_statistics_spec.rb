describe SiteStatistics do
  subject(:query) { SiteStatistics.new }

  describe 'cached_stats' do
    # describe 'traffic' do
    #   let(:traffic) { 'traff' }
    #   before do
    #     allow(YandexMetrika)
    #       .to receive(:call)
    #       .with(SiteStatistics::METRIKA_MONTHS)
    #       .and_return traffic
    #   end

    #   its(:traffic) { is_expected.to eq traffic }
    # end

    describe 'comments' do
      let!(:comments) { create_list :comment, 1, user: user }

      its(:comments) { is_expected.to have_at_least(180).items }
      its(:comments_count) { is_expected.to eq comments.last.id }
    end

    describe 'users' do
      let!(:users) { create_list :user, 2, created_at: Time.zone.yesterday + 8.hours }

      its(:users_count) { is_expected.to eq User.last.id }
      its(:users) { is_expected.to have_at_least(180).items }
      it do
        expect(query.users.last[:date]).to eq Time.zone.yesterday.to_s
        expect(query.users.last[:count]).to be_between 2, 4
      end
    end
  end
end
