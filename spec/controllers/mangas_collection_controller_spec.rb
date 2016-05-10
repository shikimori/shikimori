describe MangasCollectionController do
  let!(:manga_1) { create :manga }
  let!(:manga_2) { create :manga }

  ['guest', 'user'].each do |user|
    context user do
      include_context :authenticated, :user if user == 'user'

      describe '#index' do
        describe 'html' do
          before { get :index }

          it do
            expect(response.content_type).to eq 'text/html'
            expect(response).to have_http_status :success
          end
        end

        describe 'json' do
          before { get :index, format: 'json' }

          it do
            expect(response.content_type).to eq 'application/json'
            expect(response).to have_http_status :success
          end
        end
      end

      describe '#search' do
        before { get :index, search: 'test' }

        it do
          expect(response.content_type).to eq 'text/html'
          expect(response).to have_http_status :success
        end
      end
    end
  end
end
