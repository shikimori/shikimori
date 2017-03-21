# frozen_string_literal: true

describe Topics::Generate::UserTopic do
  subject { service.call }

  let(:locale) { 'ru' }
  let(:service) { Topics::Generate::UserTopic.new model, user, locale }

  shared_examples_for :topic do
    context 'without existing topic' do
      it do
        expect { subject }.to change(Topic, :count).by 1
        is_expected.to have_attributes(
          forum_id: Topic::FORUM_IDS[model.class.name],
          generated: true,
          linked: model,
          user: user,
          locale: locale
        )

        expect(subject.created_at.to_i).to eq model.created_at.to_i
        expect(subject.updated_at.to_i).to eq model.updated_at.to_i
      end
    end

    context 'with existing topic' do
      let!(:topic) do
        create :"#{model.class.name.underscore}_topic",
          linked: model,
          locale: topic_locale
      end

      context 'for the same locale' do
        let(:topic_locale) { 'ru' }
        it 'does not generate new topic' do
          expect { subject }.not_to change(Topic, :count)
          is_expected.to eq topic
        end
      end

      context 'for different locale' do
        let(:topic_locale) { 'en' }
        it 'generates topic for new locale' do
          expect { subject }.to change(Topic, :count).by 1
          is_expected.not_to eq topic
        end
      end
    end
  end

  context 'contest' do
    let(:model) { create :contest }
    let(:user) { model.user }
    it_behaves_like :topic
  end

  context 'cosplay gallery' do
    let(:model) { create :cosplay_gallery }
    let(:user) { seed :cosplay_user }
    it_behaves_like :topic
  end

  context 'club' do
    let(:model) { create :club }
    let(:user) { model.owner }
    it_behaves_like :topic
  end

  context 'review' do
    let(:model) { create :review }
    let(:user) { model.user }
    it_behaves_like :topic
  end
end
