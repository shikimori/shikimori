# frozen_string_literal: true

describe Topics::Generate::EntryTopic do
  subject do
    described_class.call(
      model: model,
      user: user
    )
  end

  let(:locale) { 'ru' }
  let(:user) { BotsService.get_poster }

  shared_examples_for :topic do
    context 'without existing topic' do
      it do
        expect { subject }.to change(Topic, :count).by 1
        is_expected.to have_attributes(
          forum_id: Topic::FORUM_IDS[model.class.name],
          generated: true,
          linked: model,
          user: user,
          is_censored: model.try(:is_censored) || false
        )

        expect(subject.created_at.to_i).to eq model.created_at.to_i
        expect(subject.updated_at).to be_nil
      end
    end

    context 'with existing topic' do
      let!(:topic) do
        create :"#{model.class.name.underscore}_topic",
          linked: model
      end

      context 'for the same locale' do
        let(:topic_locale) { 'ru' }
        it 'does not generate new topic' do
          expect { subject }.not_to change(Topic, :count)
          is_expected.to eq topic
        end
      end
    end
  end

  context 'anime' do
    let(:model) { create :anime, is_censored: [true, false].sample }
    it_behaves_like :topic
  end

  context 'manga' do
    let(:model) { create :manga, is_censored: [true, false].sample }
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
