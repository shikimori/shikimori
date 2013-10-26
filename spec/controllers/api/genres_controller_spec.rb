require 'spec_helper'

describe Api::GenresController do
  before do
    FactoryGirl.create :genre
    FactoryGirl.create :genre
    FactoryGirl.create :genre

    get :index, format: :json
  end

  it { should respond_with_content_type(:json) }
  it { should assign_to(:resources) }
end
