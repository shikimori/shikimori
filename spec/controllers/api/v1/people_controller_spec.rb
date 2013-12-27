require 'spec_helper'

describe Api::V1::PeopleController do
  describe :show do
    let(:person) { create :person }
    before { get :show, id: person.id }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
  end
end
