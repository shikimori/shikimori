describe TopicsController do
  include_context :seeds

  let(:user) { create :user, :user, :day_registered }
  let(:anime) { create :anime }

  let!(:topic) { create :topic, section: anime_section, user: user }
  let(:anime_topic) { create :topic, section: anime_section, user: user, linked: anime }

  let(:topic2) { create :topic, section: offtopic_section, user: user }

  before do
    Topic.antispam = false
    Section.instance_variable_set :@with_aggregated, nil
    Section.instance_variable_set :@real, nil
  end

  describe '#index', :focus do
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
      before { get :index, section: anime_section.to_param }

      it do
        expect(assigns(:view).topics).to have(2).items
        expect(response).to have_http_status :success
      end
    end

    context 'subsection' do
      context 'one topic' do
        before { get :index, section: anime_section.to_param, linked: anime.to_param }
        it { expect(response).to redirect_to UrlGenerator.instance.topic_url(anime_topic) }
      end

      context 'multiple topics' do
        let!(:anime_topic2) { create :topic, section: anime_section, user: user, linked: anime }
        before { get :index, section: anime_section.to_param, linked: anime.to_param }

        it do
          expect(assigns(:view).topics).to have(2).items
          expect(response).to have_http_status :success
        end
      end
    end
  end

  describe '#show' do
    context 'no linked' do
      before { get :show, id: topic.to_param, section: anime_section.to_param }
      it { expect(response).to have_http_status :success }
    end

    context 'missing linked' do
      before { get :show, id: anime_topic.to_param, section: anime_section.to_param }
      it { expect(response).to redirect_to topic_url(anime_topic) }
    end

    context 'wrong linked' do
      before { get :show, id: anime_topic.to_param, section: anime_section.to_param, linked: "#{anime.to_param}test" }
      it { expect(response).to redirect_to topic_url(anime_topic) }
    end

    context 'with linked' do
      before { get :show, id: anime_topic.to_param, section: anime_section.to_param, linked: anime.to_param }
      it { expect(response).to have_http_status :success }
    end
  end

  describe '#new' do
    context 'guest' do
      it { expect{get :new, section: anime_section.to_param}.to raise_error CanCan::AccessDenied }
    end

    context 'authenticated' do
      before { sign_in user }
      before { get :new, section: anime_section.to_param, topic: { user_id: user.id, section_id: anime_section.id } }
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
    let(:topic_params) {{ user_id: user.id, section_id: anime_section.id, title: 'title', text: 'text', linked_id: anime.id, linked_type: Anime.name }}
    context 'guest' do
      it { expect{post :create, section: anime_section.to_param, topic: topic_params}.to raise_error CanCan::AccessDenied }
    end

    context 'authenticated' do
      before { sign_in user }

      context 'invalid params' do
        before { post :create, section: anime_section.to_param, topic: { user_id: user.id, section_id: anime_section.id } }

        it do
          expect(assigns(:topic)).to_not be_valid
          expect(response).to have_http_status :success
        end
      end

      context 'valid params' do
        let(:text) { 'test' }
        before { post :create, section: anime_section.to_param, topic: topic_params }

        it do
          expect(resource).to have_attributes topic_params
          expect(response).to redirect_to section_topic_url(section: resource.section, id: resource, linked: resource.linked)
        end
      end
    end
  end

  describe '#update' do
    let(:topic_params) {{ user_id: user.id, section_id: anime_section.id, title: 'title', text: 'text', linked_id: anime.id, linked_type: Anime.name }}

    context 'guest' do
      it { expect{post :update, section: anime_section.to_param, id: topic.id, topic: topic_params}.to raise_error CanCan::AccessDenied }
    end

    context 'authenticated' do
      before { sign_in user }

      context 'vlid_params params' do
        before { post :update, id: topic.id, topic: { user_id: user.id, title: '' } }
        it do
          expect(resource).to_not be_valid
          expect(response).to have_http_status :success
        end
      end

      context 'valid params' do
        before { post :update, section: anime_section.to_param, id: topic.id, topic: topic_params }

        it do
          expect(resource).to have_attributes topic_params
          expect(response).to redirect_to section_topic_url(
            section: resource.section, id: resource, linked: resource.linked)
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
