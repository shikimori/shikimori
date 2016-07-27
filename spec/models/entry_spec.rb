describe Entry do
  describe 'instance methods' do
    let(:user) { create :user }
    let(:user2) { create :user }
    let(:entry) { create :entry, user: user }

    context 'comment was deleted' do
      it 'updated_at is set to created_at of last comment' do
        first = second = third = nil
        Comment.wo_antispam do
          first = create :comment, commentable: entry, created_at: 2.days.ago, body: 'first'
          second = create :comment, commentable: entry, created_at: 1.day.ago, body: 'second'
          third = create :comment, commentable: entry, created_at: 30.minutes.ago, body: 'third'
        end
        third.destroy
        expect(first.commentable.reload.updated_at.to_i).to eq(second.created_at.to_i)
      end
    end

    describe '#original_body & #appended_body' do
      let(:entry) { build :entry, body: body, generated: is_generated }
      let(:body) { 'test[wall][/wall]' }

      context 'entry' do
        let(:is_generated) { false }

        context 'with wall' do
          it { expect(entry.original_body).to eq 'test' }
          it { expect(entry.appended_body).to eq '[wall][/wall]' }
        end

        context 'without wall' do
          let(:body) { 'test' }
          it { expect(entry.original_body).to eq 'test' }
          it { expect(entry.appended_body).to eq '' }
        end
      end

      context 'generated' do
        let(:is_generated) { true }

        context 'with wall' do
          it { expect(entry.original_body).to eq 'test[wall][/wall]' }
          it { expect(entry.appended_body).to eq '' }
        end

        context 'without wall' do
          let(:body) { 'test' }
          it { expect(entry.original_body).to eq 'test' }
          it { expect(entry.appended_body).to eq '' }
        end
      end
    end
  end
end
