shared_examples :moderatable_concern do |type|
  describe 'moderatable concern' do
    let(:user) { seed :user }
    let(:model) { create type, :with_topics, user: user }

    describe 'state_machine' do
      # does not work with renamed state field
      # it { is_expected.to have_states :pending, :accepted, :rejected }
      # it { is_expected.to handle_events :accept, :reject, when: :pending }
      # it { is_expected.to reject_events :accept, :reject, when: :accepted }
      # it { is_expected.to reject_events :accept, :reject, when: :rejected }

      describe '#accept' do
        subject! { model.accept user }
        it { expect(model.approver).to eq user }
      end

      describe '#reject' do
        subject! { model.reject user }
        it { expect(model.approver).to eq user }
      end
    end

    describe 'instance methods' do
      describe '#to_offtopic' do
        subject! { model.reject! user }
        it do
          expect(model.topic(model.locale).forum_id).to eq Forum::OFFTOPIC_ID
        end
      end
    end
  end
end
