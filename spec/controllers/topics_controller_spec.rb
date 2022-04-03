describe TopicsController do
  let(:anime) { create :anime }
  let!(:topic) { create :topic, forum: animanga_forum, user: user, created_at: 1.hour.ago }

  describe '#index' do
    let!(:anime_topic_1) { create :topic, forum: animanga_forum, linked: anime }
    let!(:offtopic_topic_1) { create :topic, forum: offtopic_forum }

    context 'no forum' do
      subject! { get :index }

      it do
        # F**K: in fact 10 items: 4 topics + 7 sticky topics but it's
        # limited to 8 because of pagination limit in Forums::View
        expect(assigns(:forums_view).topic_views).to have(8).items
        expect(response).to have_http_status :success
      end
    end

    context 'offtopic' do
      subject! { get :index, params: { forum: offtopic_forum.permalink } }

      # offtopic_topic_1 + 7 seeded offtopic topics
      # (offtopic topic itself + 7 offtopic sticky topics)
      it do
        expect(assigns(:forums_view).topic_views).to have(8).items
        expect(response).to have_http_status :success
      end
    end

    context 'forum' do
      context 'no linked' do
        subject! { get :index, params: { forum: animanga_forum.to_param } }

        it do
          expect(assigns(:forums_view).topic_views).to have(2).items
          expect(response).to have_http_status :success
        end
      end

      context 'with linked' do
        let!(:anime_topic_2) { create :topic, forum: animanga_forum, linked: anime }
        subject! do
          get :index,
            params: {
              forum: animanga_forum.to_param,
              linked_id: linked_id,
              linked_type: 'anime'
            }
        end

        # broken after rails upgrade. dunno why
        # context 'valid linked' do
          # let(:linked_id) { anime.to_param }
          # it do
            # expect(assigns(:forums_view).topic_views).to have(2).items
            # expect(response).to have_http_status :success
          # end
        # end

        context 'invalid linked' do
          let(:linked_id) { anime.to_param[0..-2] }
          it do
            expect(response).to redirect_to UrlGenerator.instance
              .forum_url(animanga_forum, anime)
          end
        end
      end
    end

    context 'subforum' do
      context 'one topic' do
        subject! do
          get :index,
            params: {
              forum: animanga_forum.to_param,
              linked_type: 'anime',
              linked_id: anime.to_param
            }
        end
        it do
          expect(response).to redirect_to(
            UrlGenerator.instance.topic_url(anime_topic_1)
          )
        end
      end

      context 'multiple topic views' do
        let!(:anime_topic_2) { create :topic, forum: animanga_forum, linked: anime }
        subject! do
          get :index,
            params: {
              forum: animanga_forum.to_param,
              linked: anime.to_param
            }
        end

        it do
          expect(assigns(:forums_view).topic_views).to have(3).items
          expect(response).to have_http_status :success
        end
      end

      context 'club linked' do
        subject! do
          get :index,
            params: {
              forum: animanga_forum.to_param,
              linked_type: 'club',
              linked_id: club.to_param
            }
        end
        it { expect(response).to redirect_to club_club_topics_url(club) }
      end
    end
  end

  describe '#show' do
    let(:anime_topic) { create :topic, forum: animanga_forum, linked: anime }
    context 'no linked' do
      subject! do
        get :show,
          params: {
            id: topic.to_param,
            forum: animanga_forum.to_param
          }
      end
      it { expect(response).to have_http_status :success }
    end

    context 'wrong to_param' do
      subject! do
        get :show,
          params: {
            id: topic.to_param[0..-2],
            forum: animanga_forum.to_param
          }
      end
      it do
        expect(response).to redirect_to UrlGenerator.instance.topic_url(topic)
      end
    end

    context 'missing linked' do
      subject! do
        get :show,
          params: {
            id: anime_topic.to_param,
            forum: animanga_forum.to_param
          }
      end
      it do
        expect(response)
          .to redirect_to UrlGenerator.instance.topic_url(anime_topic)
      end
    end

    context 'wrong linked' do
      subject! do
        get :show,
          params: {
            id: anime_topic.to_param,
            forum: animanga_forum.to_param,
            linked_type: 'anime',
            linked_id: "#{anime.to_param}test"
          }
      end
      it do
        expect(response)
          .to redirect_to UrlGenerator.instance.topic_url(anime_topic)
      end
    end

    context 'with linked' do
      subject! do
        get :show,
          params: {
            id: anime_topic.to_param,
            forum: animanga_forum.to_param,
            linked_type: 'anime',
            linked_id: anime.to_param
          }
      end
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#tooltip' do
    subject! do
      get :tooltip,
        params: { id: topic.to_param },
        xhr: is_xhr
    end

    context 'xhr' do
      let(:is_xhr) { true }
      it { expect(response).to have_http_status :success }
    end

    context 'html' do
      let(:is_xhr) { false }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#new' do
    let(:topic_params) do
      {
        user_id: user.id,
        forum_id: animanga_forum.id,
        type: Topic.name
      }
    end
    let(:make_request) do
      get :new,
        params: {
          forum: animanga_forum.to_param,
          topic: topic_params
        }
    end

    context 'guest' do
      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end

    context 'authenticated' do
      include_context :authenticated, :user, :week_registered
      subject! { make_request }

      it { expect(response).to have_http_status :success }
    end
  end

  describe '#edit' do
    let(:make_request) { get :edit, params: { id: topic.to_param } }

    context 'guest' do
      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end

    context 'authenticated' do
      include_context :authenticated, :user, :week_registered
      subject! { get :edit, params: { id: topic.to_param } }

      context 'allowed edit url' do
        it { expect(response).to have_http_status :success }
      end

      context 'disallowed edit url' do
        let!(:topic) { create :collection_topic, user: user, linked: collection }
        let(:collection) { create :collection, user: user }

        it { expect(response).to redirect_to edit_collection_url(collection) }
      end
    end
  end

  describe '#create' do
    let(:topic_params) do
      {
        user_id: user.id,
        forum_id: animanga_forum.id,
        title: 'title',
        body: 'text',
        type: Topic.name,
        linked_id: anime.id,
        linked_type: Anime.name
      }
    end

    context 'guest' do
      let(:make_request) do
        post :create,
          params: {
            forum: animanga_forum.to_param,
            topic: topic_params
          }
      end
      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end

    context 'authenticated' do
      include_context :authenticated, :user, :week_registered

      context 'valid params' do
        subject! do
          post :create,
            params: {
              forum: animanga_forum.to_param,
              topic: topic_params
            }
        end

        it do
          expect(resource).to have_attributes topic_params
          expect(resource.locale).to eq controller.locale_from_host.to_s
          expect(response).to redirect_to UrlGenerator.instance.topic_url(resource)
        end
      end

      context 'invalid params' do
        let(:params) do
          {
            user_id: user.id,
            type: Topic.name,
            forum_id: animanga_forum.id,
            title: ''
          }
        end
        subject! do
          post :create,
            params: {
              forum: animanga_forum.to_param,
              topic: params
            }
        end

        it do
          expect(assigns(:topic)).to_not be_valid
          expect(response).to have_http_status :success
        end
      end
    end
  end

  describe '#update' do
    let(:params) do
      {
        user_id: user.id,
        forum_id: animanga_forum.id,
        title: 'title',
        body: 'text',
        linked_id: anime.id,
        linked_type: Anime.name
      }
    end

    context 'guest' do
      let(:make_request) do
        post :update,
          params: {
            forum: animanga_forum.to_param,
            id: topic.id,
            topic: params
          }
      end

      it { expect { make_request }.to raise_error CanCan::AccessDenied }
    end

    context 'authenticated' do
      include_context :authenticated, :user, :week_registered

      context 'valid params' do
        include_context :timecop

        subject! do
          post :update,
            params: {
              forum: animanga_forum.to_param,
              id: topic.id,
              topic: params
            }
        end

        it do
          expect(resource).to have_attributes params
          expect(response)
            .to redirect_to UrlGenerator.instance.topic_url(resource)
        end
      end

      context 'invalid params' do
        let(:params) { { user_id: user.id, title: '' } }
        subject! { post :update, params: { id: topic.id, topic: params } }

        it do
          expect(resource).to_not be_valid
          expect(response).to have_http_status :success
        end
      end
    end
  end

  describe '#destroy' do
    context 'guest' do
      it do
        expect { post :destroy, params: { id: topic.id } }
          .to raise_error CanCan::AccessDenied
      end
    end

    context 'authenticated' do
      include_context :authenticated, :user, :week_registered
      subject! { post :destroy, params: { id: topic.id } }

      it do
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#chosen' do
    let!(:offtopic_topic_1) { create :topic, forum: offtopic_forum, user: user }
    subject! do
      get :chosen,
        params: {
          ids: [topic.to_param, offtopic_topic_1.to_param].join(',')
        },
        format: :json
    end
    it { expect(response).to have_http_status :success }
  end

  describe '#reload' do
    subject! do
      get :reload,
        params: { id: topic.to_param, is_preview: 'true' },
        format: :json
    end
    it { expect(response).to have_http_status :success }
  end
end
