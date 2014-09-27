require 'spec_helper'

describe PeopleController do
  let!(:person) { create :person, name: 'test', mangaka: true }
  let(:json) { JSON.parse response.body }

  describe :index do
    let!(:person_2) { create :person, mangaka: false }
    before { get :index, search: 'test', kind: 'mangaka' }

    it { should respond_with :success }
    it { expect(assigns :people).to eq [person] }
  end

  describe :show do
    let!(:person) { create :person, :with_thread, name: 'test', mangaka: true }
    before { get :show, id: person.to_param }
    it { should respond_with :success }
  end

  describe :works do
    let!(:manga) { create :manga, person_roles: [create(:person_role, person: person, role: 'Director')] }
    before { get :works, id: person.to_param }
    it { should respond_with :success }
  end

  describe :comments do
    let!(:person) { create :person, :with_thread, name: 'test', mangaka: true }

    context :no_comments do
      before { get :comments, id: person.to_param }
      it { should redirect_to person_url(person) }
    end

    context :with_comments do
      let!(:comment) { create :comment, commentable: person.thread }
      before { person.thread.update comments_count: 1 }
      before { get :comments, id: person.to_param }
      it { should respond_with :success }
    end
  end

  describe :tooltip do
    before { get :tooltip, id: person.to_param }
    it { should respond_with :success }
  end

  describe :autocomplete do
    ['mangaka', 'seyu', 'producer'].each do |kind|
      describe kind do
        let!(:person_1) { create :person, kind => true, name: 'Fffff' }
        let!(:person_2) { create :person, kind => true, name: 'zzz Ffff' }
        let!(:person_3) { create :person, name: 'Ffff' }
        before { get :autocomplete, search: 'Fff', kind: kind }

        it { should respond_with :success }
        it { should respond_with_content_type :json }
      end
    end
  end
end
