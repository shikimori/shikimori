describe TopicsController do
  let!(:anime_section) { create :section, id: 1, permalink: 'a', name: 'Аниме' }
  let!(:offtopic_section) { create :section, :offtopic }

  let(:user) { create :user, :user }
  let(:anime) { create :anime }

  let!(:topic) { create :topic, section: anime_section, user: user }
  let(:anime_topic) { create :topic, section: anime_section, user: user, linked: anime }

  let(:section2) { create :section, id: 4, permalink: 's', name: 'Сайт' }
  let(:topic2) { create :topic, section: section2, user: user }

  before do
    Topic.antispam = false
    Section.instance_variable_set :@with_aggregated, nil
    Section.instance_variable_set :@real, nil
  end

  describe '#index' do
    before { anime_topic && topic2 }

    context 'no section' do
      before { get :index }
      it { expect(response).to have_http_status :success }
      it { expect(assigns :topics).to have(3).items }
    end

    context 'Section::static[:all]' do
      before { get :index, section: Section::static[:all].permalink }
      it { expect(response).to have_http_status :success }
      it { expect(assigns :topics).to have(3).items }
    end

    context 'section' do
      before { get :index, section: anime_section.to_param }
      it { expect(response).to have_http_status :success }
      it { expect(assigns :topics).to have(2).items }
    end

    context 'subsection' do
      context 'one topic' do
        before { get :index, section: anime_section.to_param, linked: anime.to_param }
        it { expect(response).to redirect_to topic_url(anime_topic) }
      end

      context 'multiple topics' do
        let!(:anime_topic2) { create :topic, section: anime_section, user: user, linked: anime }
        before { get :index, section: anime_section.to_param, linked: anime.to_param }
        it { expect(response).to have_http_status :success }
        it { expect(assigns :topics).to have(2).items }
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
        it { expect(response).to have_http_status :success }
        it { expect(assigns(:topic)).to_not be_valid }
      end

      context 'valid params' do
        let(:text) { 'test' }
        before { post :create, section: anime_section.to_param, topic: topic_params }
        it { expect(response).to redirect_to section_topic_url(section: resource.section, id: resource, linked: resource.linked) }
        it { expect(resource).to have_attributes topic_params }
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
        it { expect(response).to have_http_status :success }
        it { expect(assigns(:resource)).to_not be_valid }
      end

      context 'valid params' do
        before { post :update, section: anime_section.to_param, id: topic.id, topic: topic_params }
        it { expect(response).to redirect_to section_topic_url(section: resource.section, id: resource, linked: resource.linked) }
        it { expect(resource).to have_attributes topic_params }
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

      it { expect(response).to have_http_status :success }
      it { expect(response.content_type).to eq 'application/json' }
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
