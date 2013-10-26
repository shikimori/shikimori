shared_examples_for :entry_show_wo_json do |page|
  let(:redirect_url) { send("#{assigns(:entry).class.name.downcase}_url", entry) }

  context 'guest' do
    context 'to_param' do
      before { get :show, id: entry.to_param, page: 'info' }

      it { should respond_with :success }
      it { should respond_with_content_type :html }
    end

    context 'id' do
      before { get :show, id: entry.id, page: 'info' }
      it { should redirect_to redirect_url }
    end
  end

  context 'user' do
    before { sign_in user }

    describe 'html' do
      before { get :show, id: entry.to_param, page: 'info', format: 'html' }
      it { should respond_with :success }
      it { should respond_with_content_type :html }
    end
  end
end

shared_examples_for :entry_show do |page|
  it_should_behave_like :entry_show_wo_json, page

  context 'user' do
    before { sign_in user }

    describe 'json' do
      before { get :show, id: entry.to_param, page: 'info', format: 'json' }

      it { should respond_with :success }
      it { should respond_with_content_type :json }

      it { json.should have_key 'title_page' }
      it { json.should have_key 'content' }
    end
  end
end

shared_examples_for :entry_page do |page|
  describe page do
    before { sign_in user }

    describe 'html' do
      before { get :page, id: entry.to_param, page: page, format: 'html' }

      it { should respond_with :success }
      it { should respond_with_content_type :html }
    end

    describe 'json' do
      before { get :page, id: entry.to_param, page: page, format: 'json' }

      it { assigns(:director).partial.should eq "#{assigns(:director).send(:view_root)}/#{page}" }
      it { should respond_with :success }
      it { should respond_with_content_type :json }
    end
  end
end

shared_examples_for :entry_edit do |subpage|
  describe subpage do
    context 'guest user' do
      describe 'html' do
        before { get :edit, id: entry.to_param, page: 'edit', subpage: subpage.to_s, format: 'html' }
        it { should respond_with :redirect }
      end

      describe 'json' do
        before { get :edit, id: entry.to_param, page: 'edit', format: 'json' }
        it { should respond_with 401 }
      end
    end

    context 'signed_in user' do
      before { sign_in user }

      describe 'html' do
        before { get :edit, id: entry.to_param, page: 'edit', subpage: subpage.to_s, format: 'html' }

        it { should respond_with :success }
        it { should respond_with_content_type :html }
      end

      describe 'json' do
        before { get :edit, id: entry.to_param, page: 'edit', subpage: subpage.to_s, format: 'json' }

        it { assigns(:director).partial.should eq "#{assigns(:director).send(:view_root)}/edit/#{subpage}" }
        it { should respond_with :success }
        it { should respond_with_content_type :json }
      end
    end
  end
end
