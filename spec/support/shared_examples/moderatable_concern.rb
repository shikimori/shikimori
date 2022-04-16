shared_examples :moderatable_concern do |type|
  describe 'moderatable concern' do
    let(:model) do
      create type, :with_topics,
        moderation_state: moderation_state,
        user: user
    end
    let(:moderation_state) { Types::Moderatable::State[:pending] }

    describe 'validations' do
      let(:model) { build type, moderation_state: moderation_state }

      context 'pending' do
        let(:moderation_state) { Types::Moderatable::State[:pending] }
        it { expect(model).to_not validate_presence_of :approver }
      end

      [
        Types::Moderatable::State[:accepted],
        Types::Moderatable::State[:rejected]
      ].each do |state|
        context state do
          let(:moderation_state) { state }
          it { expect(model).to validate_presence_of :approver }
        end
      end
    end

    describe 'aasm' do
      subject { build :collection, state }

      context 'pending' do
        let(:state) { Types::Moderatable::State[:pending] }

        it { is_expected.to have_state(state).on(:moderation_state) }
        it { is_expected.to allow_transition_to(:accepted).on(:moderation_state) }
        it { is_expected.to transition_from(state).to(:accepted).on_event(:accept).on(:moderation_state) }
        it { is_expected.to allow_transition_to(:rejected).on(:moderation_state) }
        it { is_expected.to transition_from(state).to(:rejected).on_event(:reject).on(:moderation_state) }
      end

      context 'accepted' do
        let(:state) { Types::Moderatable::State[:accepted] }

        it { is_expected.to have_state(state).on(:moderation_state) }
        it { is_expected.to allow_transition_to(:pending).on(:moderation_state) }
        it { is_expected.to transition_from(state).to(:pending).on_event(:cancel).on(:moderation_state) }
        it { is_expected.to_not allow_transition_to(:rejected).on(:moderation_state) }
      end

      context 'rejected' do
        let(:state) { Types::Moderatable::State[:rejected] }

        it { is_expected.to have_state(state).on(:moderation_state) }
        it { is_expected.to_not allow_transition_to(:pending).on(:moderation_state) }
        it { is_expected.to_not allow_transition_to(:accepted).on(:moderation_state) }
      end

      #
      # context 'opened' do
      #   let(:state) { Types::Moderatable::State[:opened] }
      #
      #   it { is_expected.to have_state state }
      #   it { is_expected.to_not allow_transition_to :pending }
      #   it { is_expected.to allow_transition_to :accepted }
      #   it { is_expected.to transition_from(state).to(:accepted).on_event(:accept) }
      #   it { is_expected.to allow_transition_to :rejected }
      #   it { is_expected.to transition_from(state).to(:rejected).on_event(:reject) }
      # end
      #
      # context 'transition to accepted' do
      #   let(:state) do
      #     [
      #       Types::Moderatable::State[:pending],
      #       Types::Moderatable::State[:rejected],
      #       Types::Moderatable::State[:opened]
      #     ].sample
      #   end
      #   include_context :timecop
      #   before { allow(subject).to receive(:fill_accepted_at).and_call_original }
      #   before { subject.accept! }
      #   it do
      #     expect(subject).to have_received :fill_accepted_at
      #     expect(subject.accepted_at).to be_within(0.1).of Time.zone.now
      #     expect(subject).to be_persisted
      #     expect(subject).to_not be_changed
      #   end
      # end
    end

    describe 'instance methods' do
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
