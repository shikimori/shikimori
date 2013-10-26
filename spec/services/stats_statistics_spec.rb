require 'spec_helper'

describe SiteStatistics do
  subject { SiteStatistics.new }

  describe :cached_stats do

    describe :traffic do
      let(:traffic) { 'traff' }
      before { YandexMetrika.any_instance.stub(:traffic_for_monthes).with(SiteStatistics::METRIKA_MONTHS).and_return traffic }

      its(:traffic) { should eq traffic }
    end

    describe :comments do
      let(:user) { create :user }
      let!(:comments) { create_list :comment, 1, user: user, commentable: create(:topic, user: user) }

      its(:comments) { should have_at_least(180).items }
      its(:comments_count) { should eq comments.last.id }
    end

    describe :users do
      let!(:users) { create_list :user, 2 }

      its(:users) { should have_at_least(180).items }
      its(:users_count) { should eq users.last.id }
    end
  end
end
