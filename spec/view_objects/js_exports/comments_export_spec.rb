describe JsExports::CommentsExport do
  let(:tracker) { JsExports::CommentsExport.instance }
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
      tracker.export user_1
    end

    let(:comment_1) { create :comment }
    let(:comment_2) { create :comment }

    let(:user_1) { create :user }
    let(:user_2) { create :user }

    let!(:comment_viewing_1) { create :comment_viewing, viewed: comment_1, user: user_1 }
    let!(:comment_viewing_2) { create :comment_viewing, viewed: comment_2, user: user_2 }

    let(:export_1) { tracker.export user_1 }
    let(:export_2) { tracker.export user_2 }

    it do
      expect(export_1).to eq [{
        id: comment_1.id,
        is_viewed: true,
        user_id: comment_1.user_id
      }, {
        id: comment_2.id,
        is_viewed: false,
        user_id: comment_2.user_id
      }]
      expect(export_2).to eq [{
        id: comment_1.id,
        is_viewed: false,
        user_id: comment_1.user_id
      }, {
        id: comment_2.id,
        is_viewed: true,
        user_id: comment_2.user_id
      }]
    end
  end
end
