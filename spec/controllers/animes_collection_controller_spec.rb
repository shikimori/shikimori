describe AnimesCollectionController do
  ['anime', 'manga'].each do |type|
    before do
      create type.to_sym
      create type.to_sym
    end

    ['guest', 'user'].each do |user|
      context type do
        context user do
          before do
            sign_in create(:user) if user == 'user'
          end

          describe 'index' do
            describe 'html' do
              before { get :index, klass: type }

              it { should respond_with :success }
              it { expect(response.content_type).to eq 'text/html' }
            end

            describe 'json' do
              before { get :index, klass: type, format: 'json' }

              it { should respond_with :success }
              it { expect(response.content_type).to eq 'application/json' }
            end
          end

          describe 'search' do
            before { get :index, klass: type, search: 'test' }

            it { should respond_with :success }
            it { expect(response.content_type).to eq 'text/html' }
          end

          describe 'season' do
            describe 'html' do
              before { get :index, klass: type, season: 'summer_2012' }

              it { should respond_with :success }
              it { expect(response.content_type).to eq 'text/html' }
            end

            describe 'json' do
              before { get :index, klass: type, season: 'summer_2012', format: 'json' } 

              it { should respond_with :success }
              it { expect(response.content_type).to eq 'application/json' }
            end
          end if type == 'anime'
        end
      end
    end
  end
end
