require 'spec_helper'

describe UserRate do
  describe :relations do
    it { should belong_to :target }
    it { should belong_to :user }
    it { should belong_to :anime }
    it { should belong_to :manga }
  end

  describe :callbacks do

    context :create do
      let(:user_rate) { build :user_rate, status: 0 }
      after { user_rate.save }

      it { expect(user_rate).to receive :smart_process_changes }
    end

    context :update do
      let(:user_rate) { create :user_rate, status: 0 }
      after { user_rate.update status: 1 }

      it { expect(user_rate).to receive :smart_process_changes }
    end
  end

  describe :instance_methods do
    let(:episodes) { 10 }
    let(:volumes) { 15 }
    let(:chapters) { 100 }

    [[Anime, {episodes: 10}, ['episodes']], [Manga, {volumes: 15, chapters: 100}, ['volumes', 'chapters']]].each do |klass, factory_params, counters|
      describe klass do
        let(:user) { create :user }
        let(:entry) { create klass.name.downcase.to_sym, factory_params }

        #describe "updates notice" do
          #it "correctly" do
            #expect {
              #rate = UserRate.new target: entry, user: user
              #rate.update_notice 'test'
              #rate.notice.should eq 'test'
            #}.to change(UserHistory, :count).by(0)
          #end
        #end

        describe "updates status" do
          it "correctly" do
            expect {
              rate = UserRate.new target: entry, user: user
              rate.update status: UserRateStatus.get(UserRateStatus::Watching)
              rate.status.should eq(UserRateStatus.get(UserRateStatus::Watching))
            }.to change(UserHistory, :count).by(1)
          end

          it "and sets status=completed" do
            expect {
              rate = UserRate.new target: entry, user: user
              rate.update status: UserRateStatus.get(UserRateStatus::Completed)
              counters.each do |counter|
                rate.send(counter).should eq(self.send(counter))
              end
            }.to change(UserHistory, :count).by(1)
          end
        end

        #counters.each do |counter|
          #it "does not update if #{counter}>=#{UserRate::MAXIMUM_VALUE}" do
            #expect {
              #rate = UserRate.new target: entry, user: user, counter.to_sym => 4, status: UserRateStatus.get(UserRateStatus::Watching)
              #rate.send("update_#{counter}", UserRate::MAXIMUM_VALUE)
            #}.to_not change(UserHistory, :count)
          #end

          #describe "updates #{counter}" do
            #it "correctly" do
              #expect {
                #rate = UserRate.new target: entry, user: user, counter.to_sym => 4, status: UserRateStatus.get(UserRateStatus::Watching)
                #rate.send("update_#{counter}", 5)
                #rate.send(counter).should eq(5)
              #}.to change(UserHistory, :count).by(1)
            #end

            #it "even if #{counter}>entry.#{counter}" do
              #expect {
                #rate = UserRate.new target: entry, user: user, counter.to_sym => 4, status: UserRateStatus.get(UserRateStatus::Watching)
                #rate.send("update_#{counter}", 999)
                #rate.send(counter).should eq(self.send(counter))
              #}.to change(UserHistory, :count).by(1)
            #end

            #it "to 0 if #{counter} < 0" do
              #expect {
                #rate = UserRate.new target: entry, user: user, counter.to_sym => 4, status: UserRateStatus.get(UserRateStatus::Watching)
                #rate.send("update_#{counter}", -20)
                #rate.send(counter).should eq(0)
              #}.to change(UserHistory, :count).by(1)
            #end

            #it "and changes status to watching if status was planned and #{counter} was 0" do
              #rate = nil
              #expect {
                #rate = UserRate.new target: entry, user: user, counter.to_sym => 0, status: UserRateStatus.get(UserRateStatus::Planned)
                #rate.send("update_#{counter}", 3)
                #rate.status.should eq UserRateStatus.get(UserRateStatus::Watching)
              #}.to change(UserHistory, :count).by(1)
            #end

            #it "and changes status to completed if status was any and #{counter} is now = #{counter}" do
              #expect {
                #rate = UserRate.new target: entry, user: user, counter.to_sym => 0, status: UserRateStatus.get(UserRateStatus::Planned)
                #rate.send("update_#{counter}", self.send(counter))
                #rate.status.should eq(UserRateStatus.get(UserRateStatus::Completed))
              #}.to change(UserHistory, :count).by(1)
            #end

            #it "and changes #{counters.select {|v| v != counter}.first} to max value if status was any and #{counter} is now = #{counter}" do
              #another_counter = counters.select {|v| v != counter}.first
              #rate = UserRate.new target: entry, user: user, counter.to_sym => 0, status: UserRateStatus.get(UserRateStatus::Planned)

              #rate.send("update_#{counter}", self.send(counter))

              #rate.send(another_counter).should eq(self.send(another_counter))
            #end if counters.size > 1

            #it "and changes #{counters.select {|v| v != counter}.first} to 0 if #{counter} is now = 0" do
              #another_counter = counters.select {|v| v != counter}.first
              #rate = UserRate.new target: entry, user: user, counter.to_sym => 5, another_counter.to_sym => 5, status: UserRateStatus.get(UserRateStatus::Watching)

              #rate.send("update_#{counter}", 0)

              #rate.send(another_counter).should eq(0)
            #end if counters.size > 1

            #it "and changes status to planned if status was any and #{counter} was > 0 and #{counter} is now = 0" do
              #expect {
                #rate = UserRate.new target: entry, user: user, counter.to_sym => 4, status: UserRateStatus.get(UserRateStatus::Watching)
                #rate.send("update_#{counter}", 0)
                #rate.status.should eq(UserRateStatus.get(UserRateStatus::Planned))
              #}.to change(UserHistory, :count).by(1)
            #end

            #it "to 3 and then to 0, no UserHistory created" do
              #expect {
                #rate = UserRate.new target: entry, user: user, counter.to_sym => 0, status: UserRateStatus.get(UserRateStatus::Watching)
                #rate.send("update_#{counter}", 3)
                #rate.send("update_#{counter}", 0)
                #rate.status.should eq(UserRateStatus.get(UserRateStatus::Planned))
                #rate.send(counter).should eq(0)
              #}.to change(UserHistory, :count).by(0)
            #end
          #end
        #end

        #it "updates scores correctly" do
          #expect {
            #rate = UserRate.new target: entry, user: user, status: UserRateStatus.get(UserRateStatus::Watching)
            #rate.update_score(1)
            #rate.score.should eq(1)
          #}.to change(UserHistory, :count).by(1)
        #end

        #it "rate with score greater then 10 should be treated like 10" do
          #rate = UserRate.new target: entry, user: user, status: UserRateStatus.get(UserRateStatus::Watching), score: 5
          #rate.update_score(10000000000)
          #rate.score.should eq(10)
        #end

        #it "rate with score less then 0 is should be like 0" do
          #rate = UserRate.new target: entry, user: user, status: UserRateStatus.get(UserRateStatus::Watching), score: 5
          #rate.update_score(-10000000000)
          #rate.score.should eq(0)
        #end
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

    describe :manga? do
      subject { user_rate.manga? }

      context :anime do
        let(:user_rate) { build :user_rate, target_type: 'Anime' }
        it { should be false }
      end

      context :manga do
        let(:user_rate) { build :user_rate, target_type: 'Manga' }
        it { should be true }
      end
    end

    describe :smart_process_changes do
      let(:user_rate) { build :user_rate, target: build_stubbed(:anime), status: 1 }
      after { user_rate.smart_process_changes }

      it { expect(user_rate).to receive :status_updated }
    end

    describe :status_updated do
      subject(:user_rate) { create :user_rate, status, target: target }
      before { expect(UserHistory).to receive(:add).with user_rate.user_id, user_rate.target, UserHistoryAction::Status, UserRateStatus.get(UserRateStatus::Planned), build_stubbed(:user_rate, status).status }
      before { user_rate.update status: UserRateStatus.get(UserRateStatus::Planned) }

      context :anime do
        let(:target) { build_stubbed :anime, episodes: 20 }

        context :completed do
          let(:status) { :completed }
          its(:episodes) { should eq target.episodes }
        end

        context :watching do
          let(:status) { :watching }
          its(:episodes) { should be_zero }
        end
      end

      context :manga do
        let(:target) { build_stubbed :manga, volumes: 20, chapters: 25 }

        context :completed do
          let(:status) { :completed }
          its(:volumes) { should eq target.volumes }
          its(:chapters) { should eq target.chapters }
        end

        context :watching do
          let(:status) { :watching }
          its(:volumes) { should be_zero }
          its(:chapters) { should be_zero }
        end
      end
    end

    describe :counter_updated, :focus do
      subject(:user_rate) { create :user_rate, target: target, episodes: initial_episodes }

      let(:initial_episodes) { 1 }
      let(:target) { build_stubbed :anime, episodes: target_episodes }
      let(:target_episodes) { 99 }

      before { user_rate.update episodes: episodes }

      context :maximum_number do
        let(:target_episodes) { 0 }
        let(:episodes) { UserRate::MAXIMUM_VALUE + 1 }
        its(:episodes) { should eq initial_episodes }
      end

      context :negative_number do
        let(:episodes) { -1 }
        its(:episodes) { should be_zero }
      end

      context :larger_than_target_number do
        let(:target_episodes) { 99 }
        let(:episodes) { 100 }
        its(:episodes) { should eq target.episodes }
      end
    end

    describe :planned? do
      subject(:rate) { build_stubbed :user_rate, :planned }

      its(:planned?) { should be true }
      its(:watching?) { should be false }
      its(:completed?) { should be false }
      its(:on_hold?) { should be false }
      its(:dropped?) { should be false }
    end

    describe :watching? do
      subject(:rate) { build_stubbed :user_rate, status: UserRateStatus.get(UserRateStatus::Watching) }

      its(:planned?) { should be false }
      its(:watching?) { should be true }
      its(:completed?) { should be false }
      its(:on_hold?) { should be false }
      its(:dropped?) { should be false }
    end

    describe :completed? do
      subject(:rate) { build_stubbed :user_rate, status: UserRateStatus.get(UserRateStatus::Completed) }

      its(:planned?) { should be false }
      its(:watching?) { should be false }
      its(:completed?) { should be true }
      its(:on_hold?) { should be false }
      its(:dropped?) { should be false }
    end

    describe :on_hold? do
      subject(:rate) { build_stubbed :user_rate, status: UserRateStatus.get(UserRateStatus::OnHold) }

      its(:planned?) { should be false }
      its(:watching?) { should be false }
      its(:completed?) { should be false }
      its(:on_hold?) { should be true }
      its(:dropped?) { should be false }
    end

    describe :dropped? do
      subject(:rate) { build_stubbed :user_rate, status: UserRateStatus.get(UserRateStatus::Dropped) }

      its(:planned?) { should be false }
      its(:watching?) { should be false }
      its(:completed?) { should be false }
      its(:on_hold?) { should be false }
      its(:dropped?) { should be true }
    end

    describe :notice_html do
      subject { build :user_rate, notice: "[b]test[/b]\ntest" }
      its(:notice_html) { should eq '<strong>test</strong><br />test' }
    end
  end
end
