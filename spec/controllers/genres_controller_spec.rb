require 'spec_helper'

describe GenresController do
  let!(:genre) { create :genre }
  before { sign_in create(:user, id: 1) }

  describe :index do
    before { get :index }
    it { should respond_with :success }
  end

  describe :edit do
    before { get :edit, id: genre.id }
    it { should respond_with :success }
  end

  describe :update do
    before { patch :update, id: genre.id, genre: { description: 'new description' } }
    it { should redirect_to genres_url }
    it { genre.reload.description.should eq 'new description' }
  end
end
