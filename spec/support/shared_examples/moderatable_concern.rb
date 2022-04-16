shared_examples :moderatable_concern do |type|
  describe 'moderatable concern' do
    subject(:model) { build type, moderation_state: moderation_state }
    let(:moderation_state) { Types::Moderatable::State[:pending] }

    describe 'validations' do
      context 'pending' do
        it { is_expected.to_not validate_presence_of :approver }
      end

      [
        Types::Moderatable::State[:accepted],
        Types::Moderatable::State[:rejected]
      ].each do |state|
        context state do
          let(:moderation_state) { state }
          it { is_expected.to validate_presence_of :approver }
        end
      end
    end

    describe 'aasm' do
      subject { build :collection, state }

      context 'pending' do
        let(:state) { Types::Moderatable::State[:pending] }
        before do
          allow(subject).to receive :fill_accept_approver
          allow(subject).to receive :fill_reject_approver
        end

        it { is_expected.to have_state(state).on(:moderation_state) }
        it { is_expected.to allow_transition_to(:accepted).on(:moderation_state) }
        it do
          is_expected.to transition_from(state)
            .to(:accepted)
            .on_event(:accept, user_2)
            .on(:moderation_state)
        end
        it { is_expected.to allow_transition_to(:rejected).on(:moderation_state) }
        it do
          is_expected.to transition_from(state)
            .to(:rejected)
            .on_event(:reject, user_2, 'zxc')
            .on(:moderation_state)
        end
      end

      context 'accepted' do
        let(:state) { Types::Moderatable::State[:accepted] }

        it { is_expected.to have_state(state).on(:moderation_state) }
        it { is_expected.to allow_transition_to(:pending).on(:moderation_state) }
        it do
          is_expected.to transition_from(state)
            .to(:pending)
            .on_event(:cancel)
            .on(:moderation_state)
        end
        it { is_expected.to_not allow_transition_to(:rejected).on(:moderation_state) }
      end

      context 'rejected' do
        let(:state) { Types::Moderatable::State[:rejected] }

        it { is_expected.to have_state(state).on(:moderation_state) }
        it { is_expected.to_not allow_transition_to(:pending).on(:moderation_state) }
        it { is_expected.to_not allow_transition_to(:accepted).on(:moderation_state) }
      end

      context 'transitions' do
        subject { create type, :with_topics, state, user: user }

        context 'transition to accepted' do
          let(:state) { Types::Moderatable::State[:pending] }
          before { allow(subject).to receive(:fill_accept_approver).and_call_original }
          before { subject.accept! user_2 }

          it do
            is_expected.to have_received(:fill_accept_approver).with user_2
            is_expected.to be_moderation_accepted
            expect(subject.approver).to eq user_2
            is_expected.to_not be_changed
          end
        end

        context 'transition to rejected' do
          let(:state) { Types::Moderatable::State[:pending] }
          before { allow(subject).to receive(:fill_reject_approver).and_call_original }
          before { subject.reject! user_2, reason }
          let(:reason) { 'zxc' }

          it do
            is_expected.to have_received(:fill_reject_approver).with user_2, reason
            is_expected.to be_moderation_rejected
            expect(subject.approver).to eq user_2
            is_expected.to_not be_changed
          end
        end
      end
    end

    describe 'instance methods' do
      let(:model) { create type, :with_topics }

      describe '#to_offtopic' do
        subject! { model.to_offtopic! }

        it do
          expect(model).to_not be_changed
          expect(model.topic(model.locale).forum_id).to eq Forum::OFFTOPIC_ID
        end
      end
    end
  end
end
