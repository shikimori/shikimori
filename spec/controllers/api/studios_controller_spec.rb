require 'spec_helper'

describe Api::StudiosController do
  before do
    FactoryGirl.create :studio
    FactoryGirl.create :studio
    FactoryGirl.create :studio

    get :index, format: :json
  end

  it { should respond_with_content_type(:json) }
  it { should assign_to(:resources) }
end
