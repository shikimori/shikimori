require 'spec_helper'

describe TopicsController do
  let(:section) { create :section, id: 1, permalink: 'a', name: 'Аниме' }

  let(:user) { create :user }
  let(:anime) { create :anime }

  let!(:topic) { create :topic, section_id: section.id, user_id: user.id }
  let(:topic_anime) { create :topic, section_id: section.id, user_id: user.id, linked_id: anime.id, linked_type: Anime.name }

  let(:section2) { create :section, id: 4, permalink: 's', name: 'Сайт' }
  let(:topic2) { create :topic, section_id: section2.id, user_id: user.id }

  before do
    Topic.antispam = false
    Section.instance_variable_set :@with_aggregated, nil
    Section.instance_variable_set :@real, nil
  end

  ['html', 'json'].each do |format|
    describe format do
      describe 'index' do
        describe 'feed' do
          it '404' do
            lambda {
              get :index, section: Section::Feed.permalink, format: format
            }.should raise_error NotFound
          end

          it 'success' do
            sign_in user
            get :index, section: Section::All.permalink, format: format
            response.should be_success
          end
        end

        describe 'sections' do
          before { topic_anime and topic2 }

          it 'all' do
            get :index, section: Section::All.permalink, format: format

            response.should be_success

            response.body.should include(topic.text)
            response.body.should include(topic_anime.text)
            response.body.should include(topic2.text)
          end

          it 'section' do
            get :index, section: section.to_param, format: format

            response.should be_success

            response.body.should include(topic.text)
            response.body.should include(topic_anime.text)

            response.body.should_not include(topic2.text)
          end

          describe 'subsection' do
            it 'redirect when only one topic' do
              section.topics.first.destroy
              get :index, section: section.to_param, linked: anime.to_param, format: format

              response.should be_redirect
            end

            it 'success' do
              create :topic, section: section, user: user, linked: anime

              get :index, section: section.to_param, linked: anime.to_param, format: format

              response.should be_success
              response.body.should include(topic_anime.text)

              response.body.should_not include(topic.text)
              response.body.should_not include(topic2.text)
            end
          end
        end
      end

      describe 'show' do
        it 'success' do
          get :show, section: section.to_param, topic: topic.to_param, format: format

          response.should be_success
          response.body.should include(topic.text)
        end

        describe 'linked' do
          before { topic_anime }

          it 'success' do
            get :show, section: section.to_param, topic: topic_anime.to_param, linked: anime.to_param, format: format

            response.should be_success
            response.body.should include(topic_anime.text)
          end

          it 'redirect' do
            get :show, section: section.to_param, topic: topic_anime.to_param, format: format

            response.should be_redirect
          end
        end
      end

      describe 'new' do
        it 'unauthorized' do
          get :new, section: section.to_param, format: format
          response.should be_unauthorized
        end

        it 'success' do
          sign_in user
          get :new, section: section.to_param, format: format
          response.should be_success
        end
      end

      describe 'edit' do
        it 'unauthorized' do
          get :edit, id: topic.id, format: format
          response.should be_unauthorized
        end

        it 'success' do
          sign_in user
          get :edit, id: topic.id, format: format
          response.should be_success
        end
      end

      describe 'create' do
        it 'unauthorized' do
          post :create, section: section.to_param
          response.should be_unauthorized
        end

        describe 'sign_in' do
          before { sign_in user }

          it 'bad params' do
            expect {
              post :create, format: format, topic: { id: 1 }
            }.to change(Topic, :count).by 0

            response.should be_unprocessible_entiy
          end

          it 'success' do
            expect {
              post :create, format: format, topic: {
                section_id: section.id,
                text: 'test text',
                title: 'test title'
              }
            }.to change(Topic, :count).by 1
            response.should be_success

            topic = Topic.last
            topic.text.should eq 'test text'
            topic.title.should eq 'test title'
            topic.user_id.should eq(user.id)
            topic.section_id.should eq(section.id)
          end

          it 'linked' do
            expect {
              post :create, format: format, topic: {
                linked_id: anime.id,
                linked_type: anime.class.name,
                section_id: section.id,
                text: 'test text',
                title: 'test title'
              }
            }.to change(Topic, :count).by 1
            response.should be_success

            topic = Topic.last
            topic.linked_id.should eq anime.id
            topic.linked_type.should eq anime.class.name
          end
        end
      end

      describe 'update' do
        it 'unauthorized' do
          patch :update, id: topic.id
          response.should be_unauthorized
        end

        it 'random user' do
          sign_in user
          topic2 = create :topic, user: create(:user)

          patch :update, id: topic2.id, format: format, topic: { text: 'test text', title: 'test title' }
          Topic.find(topic2.id).text.should eq topic2.text

          response.should be_forbidden
        end

        it 'success' do
          sign_in user

          expect {
            patch :update, id: topic.id, format: format, topic: { text: 'test text', title: 'test title' }
          }.to change(Topic, :count).by 0
          response.should be_success

          topic = Topic.last
          topic.text.should eq 'test text'
          topic.title.should eq 'test title'
        end
      end
    end
  end
end
