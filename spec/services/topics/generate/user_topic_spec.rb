describe Topics::Generate::UserTopic do
  subject(:topic) { service.call }

  let(:service) { Topics::Generate::UserTopic.new model, user }

  shared_examples_for :topic do
    let(:topics) { Topic.where(linked: model) }
    it do
      expect{subject}.to change(Topic, :count).by 1
      is_expected.to have_attributes(
        forum_id: Topic::FORUM_IDS[model.class.name],
        generated: true,
        linked: model,
        user: user
      )

      expect(topic.created_at.to_i).to eq model.created_at.to_i
      expect(topic.updated_at.to_i).to eq model.updated_at.to_i
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
