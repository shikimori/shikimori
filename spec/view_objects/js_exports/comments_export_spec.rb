describe JsExports::CommentsExport do
  let(:tracker) { described_class.instance }
  let(:comment) { build_stubbed :comment }

  before { tracker.send :cleanup }
  after { tracker.send :cleanup }

  describe '#placeholder' do
    subject { tracker.placeholder comment }
    it { is_expected.to eq comment.id.to_s }
  end

  describe '#sweep' do
    let(:html) do
      <<-HTML.strip
        <div data-track_comment="1"></div>
        <div data-track_comment="2"></div>
      HTML
    end
    before { tracker.send :track, 3 }
    subject! { tracker.sweep html }

    it do
      is_expected.to eq html
      expect(tracker.send :tracked_ids).to eq [1, 2]
    end
  end

  describe '#export' do
    before do
      tracker.send :track, comment_1.id
      tracker.send :track, comment_2.id
    end

    let(:comment_1) { create :comment, user: user_1 }
    let(:comment_2) { create :comment, user: user_2 }

    let(:user_1) { user_day_registered }
    let(:user_2) { seed(:user) }

    let!(:comment_viewing_2) do
      create :comment_viewing, viewed: comment_2, user: user_1
    end

    context 'user 1' do
      subject { tracker.export user_1, Ability.new(user_1) }

      it do
        is_expected.to eq [{
          id: comment_1.id,
          is_viewed: false,
          user_id: comment_1.user_id,
          can_destroy: true,
          can_edit: true
        }, {
          id: comment_2.id,
          is_viewed: true,
          user_id: comment_2.user_id,
          can_destroy: false,
          can_edit: false
        }]
      end
    end

    context 'user 2' do
      subject { tracker.export user_2, Ability.new(user_2) }

      it do
        is_expected.to eq [{
          id: comment_1.id,
          is_viewed: false,
          user_id: comment_1.user_id,
          can_destroy: false,
          can_edit: false
        }, {
          id: comment_2.id,
          is_viewed: false,
          user_id: comment_2.user_id,
          can_destroy: false,
          can_edit: false
        }]
      end
    end
  end
end
