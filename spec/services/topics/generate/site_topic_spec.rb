describe Topics::Generate::SiteTopic do
  let(:service) { Topics::Generate::SiteTopic.new model, user }
  let(:user) { BotsService.get_poster }

  before { service.call }

  shared_examples_for :topic do
    let(:topics) { Topic.where(linked: model) }
    it do
      expect(topics).to have(1).item
      expect(model.topic).to have_attributes(
        forum_id: Topic::FORUM_IDS[model.class.name],
        generated: true,
        linked: model,
        user: user
      )

      expect(model.topic.created_at.to_i).to eq model.created_at.to_i
      expect(model.topic.updated_at).to be_nil
    end
  end

  context 'anime' do
    let(:model) { create :anime }
    it_behaves_like :topic
  end

  context 'manga' do
    let(:model) { create :manga }
    it_behaves_like :topic
  end

  context 'character' do
    let(:model) { create :character }
    it_behaves_like :topic
  end

  context 'person' do
    let(:model) { create :person }
    it_behaves_like :topic
  end
end
