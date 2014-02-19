require 'spec_helper'

describe Api::V1::MangasController do
  describe :show do
    let(:manga) { create :manga, :with_thread }
    before { get :show, id: manga.id, format: :json }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
  end

  describe :index do
    let(:genre) { create :genre }
    let(:publisher) { create :publisher }
    let!(:manga) { create :manga, name: 'Test', aired_on: Date.parse('2014-01-01'), publishers: [publisher], genres: [genre], rating: 'R - 17+ (violence & profanity)' }
    before { get :index, page: 1, limit: 1, type: 'Manga', season: '2014', genre: genre.id.to_s, publisher: publisher.id.to_s, rating: 'NC-17', search: 'Te', order: 'ranked', format: :json }

    it { should respond_with :success }
    it { should respond_with_content_type :json }
    specify { assigns(:collection).should have(1).item }
  end
end
