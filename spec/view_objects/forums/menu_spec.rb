describe Forums::Menu do
  include_context :view_object_warden_stub
  let(:view) { Forums::Menu.new double(id: 1), nil }
  let(:user) { seed :user }

  describe '#clubs' do
    let!(:club_topic) { create :club_topic, linked: create(:club) }
    it { expect(view.clubs).to eq [club_topic] }
  end

  describe '#contests' do
    let!(:contest) { create :contest, :proposing }
    it { expect(view.contests).to have(1).item }
  end

  describe '#changeable_forums?' do
    it { expect(view.changeable_forums?).to eq false }
  end

  describe '#forums' do
    it { expect(view.forums).to be_kind_of Forums::List }
  end

  describe '#reviews' do
    let!(:review) { create :review }
    it { expect(view.reviews).to eq [review] }
  end

  describe '#sticked_topics' do
    it { expect(view.sticked_topics).to have(5).items }
  end

  describe '#new_topic_url' do
    it { expect(view.new_topic_url).to be_present }
  end
end
