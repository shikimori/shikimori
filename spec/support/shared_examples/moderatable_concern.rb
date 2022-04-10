shared_examples :moderatable_concern do |type|
  describe 'moderatable concern' do
    let(:model) { create type, :with_topics, user: user }

    describe 'aasm' do
      # does not work with renamed state field
      # it { is_expected.to have_states :pending, :accepted, :rejected }
      # it { is_expected.to handle_events :accept, :reject, when: :pending }
      # it { is_expected.to reject_events :accept, :reject, when: :accepted }
      # it { is_expected.to reject_events :accept, :reject, when: :rejected }

      describe '#accept' do
        subject! { model.accept! user }
        it do
          expect(model).to be_accepted
          expect(model.approver).to eq user
        end
      end

      describe '#reject' do
        subject! { model.reject! user }
        it do
          expect(model).to be_rejected
          expect(model.approver).to eq user
        end
      end

      describe '#cancel' do
        before { model.accept! user }
        subject! { model.cancel! }

        it { expect(model).to be_pending }
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
