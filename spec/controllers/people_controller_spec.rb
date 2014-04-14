require 'spec_helper'
describe PeopleController do
  let(:entry) { create :person, name: 'test', mangaka: true }
  let(:user) { create :user }
  before do
    1.upto(11) do
      create :person, name: 'test2', mangaka: true
    end
    create :manga, person_roles: [create(:person_role, person: entry, role: 'Director')]
    create :person
  end
  let(:json) { JSON.parse response.body }

  describe :index do
    describe :html do
      before { get :index, search: 'test', kind: 'mangaka', format: :html }

      it { should respond_with 200 }
      it { should respond_with_content_type :html }

      it { assigns(:people).should have(10).items }
      it { assigns(:people).first.best_works.should have(1).item }
    end

    describe :json do
      before { get :index, search: 'test', kind: 'mangaka', format: :json }

      it { should respond_with 200 }
      it { should respond_with_content_type :json }
      it { json.should have_key 'content' }
    end
  end

  describe :show do
    it_should_behave_like :entry_show_wo_json do
      before { create :favourite, user: user, linked: entry, kind: Favourite::Mangaka }
    end

    context 'sort: time' do
      before { get :show, id: entry.to_param, sort: 'time' }

      it { should respond_with 200 }
    end
  end

  describe :autocomplete do
    ['mangaka', 'seyu', 'producer'].each do |kind|
      describe kind do
        before do
          create :person, kind => true, name: 'Fffff'
          create :person, kind => true, name: 'zzz Ffff'
          create :person, name: 'Ffff'
          get :autocomplete, search: 'Fff', kind: kind, format: 'json'
        end

        it { should respond_with 200 }
        it { should respond_with_content_type :json }

        describe 'json' do
          it { json.should have(2).items }
          it { json.first.should have_key 'data' }
          it { json.first.should have_key 'value' }
          it { json.first.should have_key 'label' }
        end
      end
    end
  end

  describe :tooltip do
    context :to_param do
      before { get :tooltip, id: entry.to_param }

      it { should respond_with 200 }
      it { should respond_with_content_type :html }
    end

    context :id do
      before { get :tooltip, id: entry.id }
      it { should redirect_to person_tooltip_url(entry) }
    end
  end
end
