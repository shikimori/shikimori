describe TopicsController do
  include_context :seeds

  let(:user) { create :user, :user, :day_registered }
  let(:anime) { create :anime }

  let!(:topic) { create :topic, section: animanga_section, user: user }
  let(:anime_topic) { create :topic, section: animanga_section,
    user: user, linked: anime }

  let(:topic2) { create :topic, section: offtopic_section, user: user }

  before do
    Topic.antispam = false
    Section.instance_variable_set :@static, nil
    Section.instance_variable_set :@with_aggregated, nil
    Section.instance_variable_set :@real, nil
  end

  describe '#index' do
    before { anime_topic && topic2 }

    context 'no section' do
      before { get :index }

      it do
        expect(assigns(:view).topics).to have(4).items
        expect(response).to have_http_status :success
      end
    end

    context 'offtopic' do
      before { get :index, section: seed(:offtopic_section).permalink }

      it do
        expect(assigns(:view).topics).to have(2).items
        expect(response).to have_http_status :success
      end
    end

    context 'section' do
      before { get :index, section: animanga_section.to_param }

      context 'no linked' do
        it do
          expect(assigns(:view).topics).to have(2).items
          expect(response).to have_http_status :success
        end
      end

      context 'with linked' do
        let!(:anime_topic_2) { create :topic, section: animanga_section,
          user: user, linked: anime }
        before { get :index, section: animanga_section.to_param,
          linked_id: linked_id, linked_type: 'anime' }

        context 'valid linked' do
          let(:linked_id) { anime.to_param }
          it do
            expect(assigns(:view).topics).to have(2).items
            expect(response).to have_http_status :success
          end
        end

        context 'invalid linked' do
          let(:linked_id) { anime.to_param[0..-2] }
          it { expect(response).to redirect_to UrlGenerator.instance
            .section_url(animanga_section, anime) }
        end
      end
    end

    context 'subsection' do
      context 'one topic' do
        before { get :index, section: animanga_section.to_param,
          linked_type: 'anime', linked_id: anime.to_param }
        it { expect(response).to redirect_to UrlGenerator.instance.topic_url(anime_topic) }
      end

      context 'multiple topics' do
        let!(:anime_topic2) { create :topic, section: animanga_section,
          user: user, linked: anime }
        before { get :index, section: animanga_section.to_param, linked: anime.to_param }

        it do
          expect(assigns(:view).topics).to have_at_least(2).items
          expect(response).to have_http_status :success
        end
      end
    end
  end

  describe '#show' do
    context 'no linked' do
      before { get :show, id: topic.to_param, section: animanga_section.to_param }
      it { expect(response).to have_http_status :success }
    end

    context 'wrong to_param' do
      before { get :show, id: topic.to_param[0..-2], section: animanga_section.to_param }
      it { expect(response).to redirect_to UrlGenerator.instance.topic_url(topic) }
    end

    context 'missing linked' do
      before { get :show, id: anime_topic.to_param, section: animanga_section.to_param }
      it { expect(response).to redirect_to UrlGenerator.instance.topic_url(anime_topic) }
    end

    context 'wrong linked' do
      before { get :show, id: anime_topic.to_param,
        section: animanga_section.to_param,
        linked_type: 'anime', linked_id: "#{anime.to_param}test" }
      it { expect(response).to redirect_to UrlGenerator.instance.topic_url(anime_topic) }
    end

    context 'with linked' do
      before { get :show, id: anime_topic.to_param,
        section: animanga_section.to_param,
        linked_type: 'anime', linked_id: anime.to_param }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#new' do
    context 'guest' do
      let(:make_request) { get :new, section: animanga_section.to_param }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end

    context 'authenticated' do
      let(:params) {{ user_id: user.id, section_id: animanga_section.id }}
      before { sign_in user }
      before { get :new, section: animanga_section.to_param, topic: params }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#edit' do
    let(:make_request) { get :edit, id: topic.id }

    context 'guest' do
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end

    context 'authenticated' do
      before { sign_in user }
      before { get :edit, id: topic.id }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#create' do
    let(:topic_params) {{ user_id: user.id, section_id: animanga_section.id, title: 'title', text: 'text', linked_id: anime.id, linked_type: Anime.name }}

    context 'guest' do
      let(:make_request) { post :create, section: animanga_section.to_param, topic: topic_params }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end

    context 'authenticated' do
      before { sign_in user }

      context 'invalid params' do
        let(:params) {{ user_id: user.id, section_id: animanga_section.id }}
        before { post :create, section: animanga_section.to_param, topic: params }

        it do
          expect(assigns(:topic)).to_not be_valid
          expect(response).to have_http_status :success
        end
      end

      context 'valid params' do
        let(:text) { 'test' }
        before { post :create, section: animanga_section.to_param, topic: topic_params }

        it do
          expect(resource).to have_attributes topic_params
          expect(response).to redirect_to UrlGenerator.instance.topic_url(resource)
        end
      end
    end
  end

  describe '#update' do
    let(:params) {{
      user_id: user.id,
      section_id: animanga_section.id,
      title: 'title',
      text: 'text',
      linked_id: anime.id,
      linked_type: Anime.name
    }}

    context 'guest' do
      let(:make_request) { post :update, section: animanga_section.to_param,
        id: topic.id, topic: params }
      it { expect{make_request}.to raise_error CanCan::AccessDenied }
    end

    context 'authenticated' do
      before { sign_in user }

      context 'vlid_params params' do
        let(:params) {{ user_id: user.id, title: '' }}
        before { post :update, id: topic.id, topic: params }

        it do
          expect(resource).to_not be_valid
          expect(response).to have_http_status :success
        end
      end

      context 'valid params' do
        before { post :update, section: animanga_section.to_param,
          id: topic.id, topic: params }

        it do
          expect(resource).to have_attributes params
          expect(response).to redirect_to UrlGenerator.instance.topic_url(resource)
        end
      end
    end
  end

  describe '#destroy' do
    context 'guest' do
      it { expect{post :destroy, id: topic.id}.to raise_error CanCan::AccessDenied }
    end

    context 'authenticated' do
      before { sign_in user }
      before { post :destroy, id: topic.id }

      it do
        expect(response.content_type).to eq 'application/json'
        expect(response).to have_http_status :success
      end
    end
  end

  describe '#tooltip' do
    before { get :tooltip, id: topic.to_param }
    it { expect(response).to have_http_status :success }
  end

  describe '#chosen' do
    before { get :chosen, ids: [topic.to_param, topic2.to_param].join(',') }
    it { expect(response).to have_http_status :success }
  end

  describe '#reload' do
    before { get :reload, id: topic.to_param, is_preview: 'true' }
    it { expect(response).to have_http_status :success }
  end
end
