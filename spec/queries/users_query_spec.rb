describe UsersQuery do
  describe 'complete' do
    before do
      create :user, nickname: 'ffff'
      create :user, nickname: 'testt'
      create :user, nickname: 'zula zula'
      create :user, nickname: 'test'
    end
    subject { -> (phrase) { UsersQuery.new(search: phrase).complete } }

    it { expect(subject.call('test').size).to eq(2) }
    it { expect(subject.call('z').size).to eq(1) }
    it { expect(subject.call('fofo').size).to eq(0) }
  end

  describe 'bans_count' do
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
      end
    end

  end
end
