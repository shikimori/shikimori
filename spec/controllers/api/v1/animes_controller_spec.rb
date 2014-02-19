require 'spec_helper'

describe Api::V1::AnimesController do
  describe :show do
    let(:anime) { create :anime, :with_thread }
    before { get :show, id: anime.id, format: :json }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
  end

  describe :index do
    let(:genre) { create :genre }
    let(:studio) { create :studio }
    let!(:anime) { create :anime, name: 'Test', aired_on: Date.parse('2014-01-01'), studios: [studio], genres: [genre], duration: 90, rating: 'R - 17+ (violence & profanity)' }
    before { get :index, page: 1, limit: 1, type: 'TV', season: '2014', genre: genre.id.to_s, studio: studio.id.to_s, duration: 'F', rating: 'NC-17', search: 'Te', order: 'ranked', format: :json }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
    specify { assigns(:collection).should have(1).item }
  end
end
