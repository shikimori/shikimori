describe UsersQuery do
  describe '#complete' do
    let!(:user_1) { create :user, nickname: 'ffff' }
    let!(:user_2) { create :user, nickname: 'testt' }
    let!(:user_3) { create :user, nickname: 'zula zula' }
    let!(:user_4) { create :user, nickname: 'test' }

    subject { UsersQuery.new(search: phrase).complete  }

    describe 'test' do
      let(:phrase) { 'test' }
      it { should eq [user_2, user_4] }
    end

    describe 'z' do
      let(:phrase) { 'z' }
      it { should eq [user_3] }
    end

    describe 'fofo' do
      let(:phrase) { 'fofo' }
      it { should be_empty }
    end
  end

  describe '#bans_count' do
    subject { UsersQuery.new(user_id: user.id).bans_count }

    let(:user) { create :user }
    let(:comment) { create :comment, user: user }
    let(:abuse_request) { create :abuse_request, comment: comment, user: user }

    context 'warnings' do
      let!(:warnings) { create_list :ban, 2, :no_callbacks, created_at: DateTime.now - Ban::ACTIVE_DURATION + 1.minute, duration: 0, user: user, comment: comment, moderator: user, abuse_request: abuse_request }
      it { should eq 1 }

      context 'bans' do
        let!(:valid_bans) { create_list :ban, 3, :no_callbacks, created_at: DateTime.now - Ban::ACTIVE_DURATION + 1.minute, user: user, comment: comment, moderator: user, abuse_request: abuse_request }
        let!(:invalid_bans) { create :ban, :no_callbacks, created_at: DateTime.now - Ban::ACTIVE_DURATION - 1.minute, user: user, comment: comment, moderator: user, abuse_request: abuse_request }
        subject { UsersQuery.new(user_id: user.id).bans_count }

        it { should eq 4 }

        context 'banhammer bans' do
          let(:banhammer) { create :user, :banhammer }
          let!(:banhammer_ban) { create :ban, :no_callbacks, moderator: banhammer, created_at: DateTime.now - Ban::ACTIVE_DURATION + 1.minute, user: user, comment: comment, abuse_request: abuse_request }

          it { should eq 4 }
        end
      end
    end
  end

  describe '#search' do
    let!(:user_1) { create :user, nickname: 'ffff' }
    let!(:user_2) { create :user, nickname: 'testt' }
    let!(:user_3) { create :user, nickname: 'zula zula' }
    let!(:user_4) { create :user, nickname: 'test' }

    subject { UsersQuery.new(search: phrase).search  }

    describe 'test' do
      let(:phrase) { 'test' }
      it { should eq [user_4, user_2] }
    end

    describe 'z' do
      let(:phrase) { 'z' }
      it { should eq [user_3] }
    end

    describe 'fofo' do
      let(:phrase) { 'fofo' }
      it { should be_empty }
    end
  end

end
