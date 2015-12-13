describe Forums::Menu do
  let(:view) { Forums::Menu.new }

  describe '#clubs' do
    let!(:club_comment) { create :club_comment, linked: create(:group) }
    it { expect(view.clubs).to eq [club_comment] }
  end

  describe '#reviews' do
    let!(:review) { create :review }
    it { expect(view.reviews).to eq [review] }
  end

  describe '#sticked_topics' do
    it { expect(view.sticked_topics).to have(5).items }
  end
end
