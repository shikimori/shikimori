describe JsExports::ReviewsExport do
  let(:tracker) { described_class.instance }
  let(:review) { build_stubbed :review }

  before { tracker.send :cleanup }
  after { tracker.send :cleanup }

  describe '#placeholder' do
    subject { tracker.placeholder review }
    it { is_expected.to eq review.id.to_s }
  end

  describe '#sweep' do
    let(:html) do
      <<-HTML.strip
        <div data-track_review="1"></div>
        <div data-track_review="2"></div>
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
      tracker.send :track, review_1.id
      tracker.send :track, review_2.id

      Votable::Vote.call(
        votable: review_2,
        voter: user_1,
        vote: 'yes'
      )
    end

    let(:anime) { create :anime }

    let(:review_1) { create :review, anime: anime, user: user_1 }
    let(:review_2) { create :review, anime: anime, user: user_2 }

    let(:user_1) { create :user }
    let(:user_2) { create :user }

    let!(:review_viewing_1) do
      create :review_viewing, viewed: review_1, user: user_2
    end

    let(:export_1) { tracker.export user_1, Ability.new(user_1) }
    let(:export_2) { tracker.export user_2, Ability.new(user_2) }

    it do
      expect(export_1).to eq [{
        can_destroy: false,
        can_edit: false,
        id: review_1.id,
        is_viewed: true,
        user_id: review_1.user_id,
        voted_no: false,
        voted_yes: false,
        votes_against: 0,
        votes_for: 0
      }, {
        can_destroy: false,
        can_edit: false,
        id: review_2.id,
        is_viewed: false,
        user_id: review_2.user_id,
        voted_no: false,
        voted_yes: true,
        votes_against: 0,
        votes_for: 1
      }]
      expect(export_2).to eq [{
        can_destroy: false,
        can_edit: false,
        id: review_1.id,
        is_viewed: true,
        user_id: review_1.user_id,
        voted_no: false,
        voted_yes: false,
        votes_against: 0,
        votes_for: 0
      }, {
        can_destroy: false,
        can_edit: false,
        id: review_2.id,
        is_viewed: true,
        user_id: review_2.user_id,
        voted_no: false,
        voted_yes: false,
        votes_against: 0,
        votes_for: 1
      }]
    end
  end
end
