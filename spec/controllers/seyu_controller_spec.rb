require 'spec_helper'

describe SeyuController do
  let(:entry) { create :person, name: 'test', seyu: true }
  let(:user) { create :user }
  before do
    create_list :person, 11, name: 'test2', seyu: true
    character = create :character, person_roles: [create(:person_role, role: Person::SeyuRoles.sample, person: entry)]
    create :anime, characters: [character]
    create :person
  end
  let(:json) { JSON.parse response.body }

  describe 'index' do
    describe 'html' do
      before { get :index, search: 'test', kind: 'seyu', format: :html }

      it { should respond_with 200 }
      it { should respond_with_content_type :html }

      it { assigns(:people).should have(10).items }
      it { assigns(:people).first.best_works.should have(1).item }
    end

    describe 'json' do
      before { get :index, search: 'test', kind: 'seyu', format: :json }

      it { should respond_with 200 }
      it { should respond_with_content_type :json }
      it { json.should have_key 'content' }
    end
  end

  describe 'show' do
    it_should_behave_like :entry_show_wo_json do
      before { create :favourite, user: user, linked: entry, kind: Favourite::Seyu }
      let(:redirect_url) { seyu_url entry  }
    end

    context 'sort: time' do
      before { get :show, id: entry.to_param, sort: 'time' }

      it { should respond_with 200 }
    end
  end
end
