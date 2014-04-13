require 'spec_helper'

describe GenresController do
  let!(:genre) { create :genre }

  describe :index do
    before { get :index }
    it { should respond_with :success }
  end

  describe :edit do
    before { get :edit, id: genre.id }
    it { should respond_with :success }
  end

  describe :update do
  end
end
