describe Topics::Generate::UserTopic do
  let(:service) { Topics::Generate::UserTopic.new model, user }
  before { service.call }

  shared_examples_for :topic do
    let(:topics) { Topic.where(linked: model) }
    it do
      expect(topics).to have(1).item
      expect(model.topic).to have_attributes(
        forum_id: Topic::FORUM_IDS[model.class.name],
        generated: true,
        linked: model,
        user: user,
        created_at: model.created_at,
        updated_at: model.updated_at
      )
    end
  end

  context 'club' do
    let(:model) { create :club }
    let(:user) { model.owner }
    it_behaves_like :topic
  end

  context 'contest' do
    let(:model) { create :contest }
    let(:user) { model.user }
    it_behaves_like :topic
  end

  context 'cosplay gallery' do
    let(:model) { create :cosplay_gallery }
    let(:user) { create :user, id: User::COSPLAYER_ID }
    it_behaves_like :topic
  end

  context 'review' do
    let(:model) { create :review }
    let(:user) { model.user }
    it_behaves_like :topic
  end
end
