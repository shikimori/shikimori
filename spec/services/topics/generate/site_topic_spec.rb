describe Topics::Generate::SiteTopic do
  subject(:topic) { service.call }

  let(:service) { Topics::Generate::SiteTopic.new model, user }
  let(:user) { BotsService.get_poster }

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
      expect(topic.updated_at).to be_nil
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
