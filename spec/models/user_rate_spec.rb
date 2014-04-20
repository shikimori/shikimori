
require 'spec_helper'

describe UserRate do
  it { should belong_to :target }
  it { should belong_to :user }
  it { should belong_to :anime }
  it { should belong_to :manga }

  let(:episodes) { 10 }
  let(:volumes) { 15 }
  let(:chapters) { 100 }

  [[Anime, {episodes: 10}, ['episodes']], [Manga, {volumes: 15, chapters: 100}, ['volumes', 'chapters']]].each do |klass, factory_params, counters|
    describe klass do
      let(:user) { create :user }
      let(:entry) { create klass.name.downcase.to_sym, factory_params }

      describe "updates notice" do
        it "correctly" do
          expect {
            rate = UserRate.new target: entry, user: user
            rate.update_notice 'test'
            rate.notice.should eq 'test'
          }.to change(UserHistory, :count).by(0)
        end
      end

      describe "updates status" do
        it "correctly" do
          expect {
            rate = UserRate.new target: entry, user: user
            rate.update_status(UserRateStatus.get(UserRateStatus::Watching))
            rate.status.should eq(UserRateStatus.get(UserRateStatus::Watching))
          }.to change(UserHistory, :count).by(1)
        end

        it "and sets status=completed" do
          expect {
            rate = UserRate.new target: entry, user: user
            rate.update_status(UserRateStatus.get(UserRateStatus::Completed))
            counters.each do |counter|
              rate.send(counter).should eq(self.send(counter))
            end
          }.to change(UserHistory, :count).by(1)
        end
      end

      counters.each do |counter|
        it "does not update if #{counter}>=#{UserRate::MaximumNumber}" do
          expect {
            rate = UserRate.new target: entry, user: user, counter.to_sym => 4, status: UserRateStatus.get(UserRateStatus::Watching)
            rate.send("update_#{counter}", UserRate::MaximumNumber)
          }.to_not change(UserHistory, :count)
        end

        describe "updates #{counter}" do
          it "correctly" do
            expect {
              rate = UserRate.new target: entry, user: user, counter.to_sym => 4, status: UserRateStatus.get(UserRateStatus::Watching)
              rate.send("update_#{counter}", 5)
              rate.send(counter).should eq(5)
            }.to change(UserHistory, :count).by(1)
          end

          it "even if #{counter}>entry.#{counter}" do
            expect {
              rate = UserRate.new target: entry, user: user, counter.to_sym => 4, status: UserRateStatus.get(UserRateStatus::Watching)
              rate.send("update_#{counter}", 999)
              rate.send(counter).should eq(self.send(counter))
            }.to change(UserHistory, :count).by(1)
          end

          it "to 0 if #{counter} < 0" do
            expect {
              rate = UserRate.new target: entry, user: user, counter.to_sym => 4, status: UserRateStatus.get(UserRateStatus::Watching)
              rate.send("update_#{counter}", -20)
              rate.send(counter).should eq(0)
            }.to change(UserHistory, :count).by(1)
          end

          it "and changes status to watching if status was planned and #{counter} was 0" do
            rate = nil
            expect {
              rate = UserRate.new target: entry, user: user, counter.to_sym => 0, status: UserRateStatus.get(UserRateStatus::Planned)
              rate.send("update_#{counter}", 3)
              rate.status.should eq UserRateStatus.get(UserRateStatus::Watching)
            }.to change(UserHistory, :count).by(1)
          end

          it "and changes status to completed if status was any and #{counter} is now = #{counter}" do
            expect {
              rate = UserRate.new target: entry, user: user, counter.to_sym => 0, status: UserRateStatus.get(UserRateStatus::Planned)
              rate.send("update_#{counter}", self.send(counter))
              rate.status.should eq(UserRateStatus.get(UserRateStatus::Completed))
            }.to change(UserHistory, :count).by(1)
          end

          it "and changes #{counters.select {|v| v != counter}.first} to max value if status was any and #{counter} is now = #{counter}" do
            another_counter = counters.select {|v| v != counter}.first
            rate = UserRate.new target: entry, user: user, counter.to_sym => 0, status: UserRateStatus.get(UserRateStatus::Planned)

            rate.send("update_#{counter}", self.send(counter))

            rate.send(another_counter).should eq(self.send(another_counter))
          end if counters.size > 1

          it "and changes #{counters.select {|v| v != counter}.first} to 0 if #{counter} is now = 0" do
            another_counter = counters.select {|v| v != counter}.first
            rate = UserRate.new target: entry, user: user, counter.to_sym => 5, another_counter.to_sym => 5, status: UserRateStatus.get(UserRateStatus::Watching)

            rate.send("update_#{counter}", 0)

            rate.send(another_counter).should eq(0)
          end if counters.size > 1

          it "and changes status to planned if status was any and #{counter} was > 0 and #{counter} is now = 0" do
            expect {
              rate = UserRate.new target: entry, user: user, counter.to_sym => 4, status: UserRateStatus.get(UserRateStatus::Watching)
              rate.send("update_#{counter}", 0)
              rate.status.should eq(UserRateStatus.get(UserRateStatus::Planned))
            }.to change(UserHistory, :count).by(1)
          end

          it "to 3 and then to 0, no UserHistory created" do
            expect {
              rate = UserRate.new target: entry, user: user, counter.to_sym => 0, status: UserRateStatus.get(UserRateStatus::Watching)
              rate.send("update_#{counter}", 3)
              rate.send("update_#{counter}", 0)
              rate.status.should eq(UserRateStatus.get(UserRateStatus::Planned))
              rate.send(counter).should eq(0)
            }.to change(UserHistory, :count).by(0)
          end
        end
      end

      it "updates scores correctly" do
        expect {
          rate = UserRate.new target: entry, user: user, status: UserRateStatus.get(UserRateStatus::Watching)
          rate.update_score(1)
          rate.score.should eq(1)
        }.to change(UserHistory, :count).by(1)
      end

      it "rate with score greater then 10 should be treated like 10" do
        rate = UserRate.new target: entry, user: user, status: UserRateStatus.get(UserRateStatus::Watching), score: 5
        rate.update_score(10000000000)
        rate.score.should eq(10)
      end

      it "rate with score less then 0 is should be like 0" do
        rate = UserRate.new target: entry, user: user, status: UserRateStatus.get(UserRateStatus::Watching), score: 5
        rate.update_score(-10000000000)
        rate.score.should eq(0)
      end
    end
  end

  describe :anime? do
    subject { user_rate.anime? }

    context :anime do
      let(:user_rate) { build :user_rate, target_type: 'Anime' }
      it { should be true }
    end

    context :manga do
      let(:user_rate) { build :user_rate, target_type: 'Manga' }
      it { should be false }
    end
  end

  describe :notice_html do
    subject { build :user_rate, notice: "[b]test[/b]\ntest" }
    its(:notice_html) { should eq '<strong>test</strong><br />test' }
  end
end
