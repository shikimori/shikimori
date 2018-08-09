describe Users::BansCount do
  subject { Users::BansCount.call user.id }

  let(:comment) { create :comment, user: user }
  let(:abuse_request) { create :abuse_request, comment: comment, user: user }

  it { is_expected.to eq 0 }

  context 'warnings' do
    let!(:warnings) do
      create_list :ban, 2, :no_callbacks,
        created_at: DateTime.now - Ban::ACTIVE_DURATION + 1.minute,
        duration: 0,
        user: user,
        comment: comment,
        moderator: user,
        abuse_request: abuse_request
    end
    it { is_expected.to eq 1 }

    context 'bans' do
      let!(:valid_bans) do
        create_list :ban, 3, :no_callbacks,
          created_at: DateTime.now - Ban::ACTIVE_DURATION + 1.minute,
          user: user,
          comment: comment,
          moderator: user,
          abuse_request: abuse_request
      end
      let!(:invalid_bans) do
        create :ban, :no_callbacks,
          created_at: DateTime.now - Ban::ACTIVE_DURATION - 1.minute,
          user: user,
          comment: comment,
          moderator: user,
          abuse_request: abuse_request
      end

      it { is_expected.to eq 4 }

      context 'banhammer bans' do
        let(:banhammer) { create :user, :banhammer }
        let!(:banhammer_ban) do
          create :ban, :no_callbacks,
            moderator: banhammer,
            created_at: DateTime.now - Ban::ACTIVE_DURATION + 1.minute,
            user: user,
            comment: comment,
            abuse_request: abuse_request
        end

        it { is_expected.to eq 4 }
      end
    end
  end
end
