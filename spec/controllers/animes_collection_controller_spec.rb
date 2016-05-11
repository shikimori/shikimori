describe AnimesCollectionController do
  ['anime', 'manga'].each do |type|
    describe type do
      let!(:entry_1) { create type.to_sym }
      let!(:entry_2) { create type.to_sym }

      ['guest', 'user'].each do |user|
        context user do
          include_context :authenticated, :user if user == 'user'

          describe '#index' do
            describe 'html' do
              before { get :index, klass: type }

              it do
                expect(response.content_type).to eq 'text/html'
                expect(response).to have_http_status :success
              end
            end

            describe 'json' do
              before { get :index, klass: type, format: 'json' }

              it do
                expect(response.content_type).to eq 'application/json'
                expect(response).to have_http_status :success
              end
            end
          end

          describe '#search' do
            before { get :index, klass: type, search: 'test' }

            it do
              expect(response.content_type).to eq 'text/html'
              expect(response).to have_http_status :success
            end
          end

          describe '#season' do
            describe 'html' do
              before { get :index, klass: type, season: 'summer_2012' }

              it do
                expect(response.content_type).to eq 'text/html'
                expect(response).to have_http_status :success
              end
            end

            describe 'json' do
              before { get :index, klass: type, season: 'summer_2012', format: 'json' } 

              it do
                expect(response.content_type).to eq 'application/json'
                expect(response).to have_http_status :success
              end
            end
          end if type == 'anime'
        end
      end
    end
  end
end
