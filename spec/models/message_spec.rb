describe Message do
  describe 'relations' do
    it { is_expected.to belong_to :from }
    it { is_expected.to belong_to :to }
    it { is_expected.to belong_to(:linked).optional }

    it { is_expected.to validate_presence_of :from }
    it { is_expected.to validate_presence_of :to }
  end

  describe 'validations' do
    it { is_expected.to_not validate_presence_of :body }

    context 'private' do
      before { subject.kind = MessageType::PRIVATE }
      it { is_expected.to validate_presence_of :body }
      it { is_expected.to validate_length_of(:body).is_at_most(10000) }
    end

    it { is_expected.to validate_presence_of :from }
    it { is_expected.to validate_presence_of :to }
  end

  describe 'callbacks' do
    let(:user) { build_stubbed :user, :user }

    describe '#check_spam_abuse' do
      before do
        allow(Messages::CheckSpamAbuse).to receive(:call).and_return true
        allow(Users::CheckHacked).to receive(:call).and_return true
      end
      let!(:message) { create :message, :private, :with_check_spam_abuse }

      it do
        expect(Messages::CheckSpamAbuse).to have_received(:call).with message
        expect(Users::CheckHacked)
          .to have_received(:call)
          .with(
            model: message,
            user: message.from,
            text: message.body
          )
      end
    end

    describe 'after_create' do
      describe '#send_email' do
        let(:message) { build :message, kind: kind }

        before { allow(EmailNotifier.instance).to receive :private_message }
        before { message.save! }

        context 'private message' do
          let(:kind) { MessageType::PRIVATE }
          it do
            expect(EmailNotifier.instance)
            .to have_received(:private_message).with message
          end
        end

        context 'common message' do
          let(:kind) { MessageType::NOTIFICATION }
          it do
            expect(EmailNotifier.instance)
            .to_not have_received(:private_message)
          end
        end
      end
    end
  end

  describe 'instance methods' do
    describe '#delete_by' do
      let(:message) do
        create :message,
          to: user_2,
          from: build_stubbed(:user)
      end
      before { message.delete_by user }

      context 'private message' do
        context 'by from' do
          let(:user) { message.from }
          it { expect(message).to be_destroyed }
        end

        context 'by to' do
          let(:user) { message.to }

          it { expect(message).to be_persisted }
          it { expect(message.is_deleted_by_to).to eq true }
          it { expect(message).to be_read }
        end
      end

      context 'other messages' do
        let(:message) { create :message, :notification }
        let(:user) { nil }
        it { expect(message).to be_destroyed }
      end
    end
  end

  describe 'permissions' do
    let(:message) do
      build_stubbed :message,
        from: from_user,
        to: to_user,
        kind: kind,
        created_at: created_at
    end
    let(:from_user) { build_stubbed :user, :user, :day_registered }
    let(:to_user) { build_stubbed :user, :user }
    let(:created_at) { 1.minute.ago }
    let(:kind) { MessageType::PRIVATE }

    subject { Ability.new user }

    context 'guest' do
      let(:user) { nil }
      it { is_expected.to_not be_able_to :read, message }
      it { is_expected.to_not be_able_to :mark_read, message }
      it { is_expected.to_not be_able_to :create, message }
      it { is_expected.to_not be_able_to :edit, message }
      it { is_expected.to_not be_able_to :update, message }
      it { is_expected.to_not be_able_to :destroy, message }

      context 'message to admin' do
        let(:message) do
          build_stubbed :message,
            from_id: User::GUEST_ID,
            to_id: User::MORR_ID,
            kind: MessageType::PRIVATE
        end
        it { is_expected.to be_able_to :create, message }
      end
    end

    context 'user' do
      let(:user) { build_stubbed :user, :user, :day_registered }

      it { is_expected.to_not be_able_to :read, message }
      it { is_expected.to_not be_able_to :create, message }
      it { is_expected.to_not be_able_to :edit, message }
      it { is_expected.to_not be_able_to :update, message }
      it { is_expected.to_not be_able_to :destroy, message }

      context 'message owner' do
        let(:user) { from_user }

        it { is_expected.to_not be_able_to :mark_read, message }
        it { is_expected.to be_able_to :read, message }

        context 'private message' do
          let(:kind) { MessageType::PRIVATE }

          context 'not banned forever' do
            let(:from_user) { build_stubbed :user, :user, :banned, :day_registered }
            it { is_expected.to be_able_to :create, message }
          end

          context 'banned forever' do
            let(:from_user) { build_stubbed :user, :user, :forever_banned, :day_registered }
            it { is_expected.to_not be_able_to :create, message }
          end

          context 'day registered' do
            let(:from_user) { build_stubbed :user, :user, :day_registered }

            it { is_expected.to be_able_to :create, message }
            it { is_expected.to be_able_to :edit, message }
            it { is_expected.to be_able_to :update, message }
            it { is_expected.to be_able_to :destroy, message }
          end

          context 'not day registered' do
            let(:from_user) { build_stubbed :user, :user }

            it { is_expected.to_not be_able_to :create, message }
            it { is_expected.to_not be_able_to :edit, message }
            it { is_expected.to_not be_able_to :update, message }
            it { is_expected.to be_able_to :destroy, message }

            context 'message to admin' do
              let(:message) do
                build_stubbed :message,
                  from: user,
                  to_id: User::MORR_ID,
                  kind: MessageType::PRIVATE
              end

              it { is_expected.to be_able_to :create, message }
              it { is_expected.to be_able_to :edit, message }
              it { is_expected.to be_able_to :update, message }
              it { is_expected.to be_able_to :destroy, message }
            end
          end

          context 'new message' do
            let(:created_at) { 1.week.ago + 1.day }
            it { is_expected.to be_able_to :edit, message }
            it { is_expected.to be_able_to :update, message }
          end

          context 'old message' do
            let(:created_at) { 1.week.ago - 1.day }
            it { is_expected.to_not be_able_to :edit, message }
            it { is_expected.to_not be_able_to :update, message }
          end
        end

        context 'other type messages' do
          let(:kind) { MessageType::NOTIFICATION }
          it { is_expected.to_not be_able_to :create, message }
          it { is_expected.to_not be_able_to :edit, message }
          it { is_expected.to_not be_able_to :update, message }
          it { is_expected.to be_able_to :destroy, message }
        end
      end

      context 'message target' do
        let(:user) { to_user }

        it { is_expected.to be_able_to :mark_read, message }
        it { is_expected.to be_able_to :read, message }
        it { is_expected.to_not be_able_to :create, message }
        it { is_expected.to_not be_able_to :edit, message }
        it { is_expected.to_not be_able_to :update, message }

        context 'private message' do
          let(:kind) { MessageType::PRIVATE }

          context 'new message' do
            let(:created_at) { 1.minute.ago }
            it { is_expected.to be_able_to :destroy, message }
          end

          context 'old message' do
            let(:created_at) { 11.minutes.ago }
            it { is_expected.to be_able_to :destroy, message }
          end
        end

        context 'other type message' do
          let(:kind) { MessageType::NOTIFICATION }
          it { is_expected.to be_able_to :destroy, message }
        end
      end
    end
  end

  it_behaves_like :antispam_concern, :message
end
