require 'spec_helper'

describe Api::AnimesController do
  before do
    a1 = create :anime
    a1.genres << create(:genre)
    a2 = create :anime
    a2.studios << create(:studio)
    create :anime

    get :index, format: :json
  end

  it { should respond_with_content_type :json }
  it { should assign_to :resources }
end
