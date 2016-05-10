describe AnimesCollectionController do
  let!(:anime_1) { create :anime }
  let!(:anime_2) { create :anime }

  ['guest', 'user'].each do |user|
    context user do
      include_context :authenticated, :user if user == 'user'

      describe '#index' do
        describe 'html' do
          before { get :index }

          it { expect(response).to have_http_status :success }
          it { expect(response.content_type).to eq 'text/html' }
        end

        describe 'json' do
          before { get :index, format: 'json' }

          it { expect(response).to have_http_status :success }
          it { expect(response.content_type).to eq 'application/json' }
        end
      end

      describe '#search' do
        before { get :index, search: 'test' }

        it { expect(response).to have_http_status :success }
        it { expect(response.content_type).to eq 'text/html' }
      end

      describe '#season' do
        describe 'html' do
          before { get :index, season: 'summer_2012' }

          it { expect(response).to have_http_status :success }
          it { expect(response.content_type).to eq 'text/html' }
        end

        describe 'json' do
          before { get :index, season: 'summer_2012', format: 'json' } 

          it { expect(response).to have_http_status :success }
          it { expect(response.content_type).to eq 'application/json' }
        end
      end
    end
  end
end
