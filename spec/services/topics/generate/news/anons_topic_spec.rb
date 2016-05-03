describe Topics::Generate::News::AnonsTopic do
  subject(:topic) { service.call }

  let(:locale) { 'ru' }
  let(:service) { Topics::Generate::News::AnonsTopic.new model, user, locale }
  let(:user) { BotsService.get_poster }

  shared_examples_for :topic do
    context 'without existing topic' do
      it do
        expect{subject}.to change(Topic, :count).by 1
        is_expected.to have_attributes(
          forum_id: Topic::FORUM_IDS[model.class.name],
          generated: true,
          linked: model,
          user: user,
          locale: locale
        )

        expect(topic.created_at.to_i).to eq model.created_at.to_i
        expect(topic.updated_at).to be_nil
      end
    end

    context 'with existing topic' do
      let!(:topic) { create :topic, linked: model }
      it do
        expect{subject}.not_to change(Topic, :count)
        is_expected.to eq topic
      end
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
