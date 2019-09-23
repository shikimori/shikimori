describe AnimesCollectionController do
  %w[anime manga ranobe].each do |kind|
    describe kind do
      let!(:entry_1) { create kind.to_sym }
      let!(:entry_2) { create kind.to_sym }

      %w[guest user].each do |user| # rubocop:disable Performance/CollectionLiteralInLoop
        context user do
          include_context :authenticated, :user if user == 'user'

          describe '#index' do
            describe 'html' do
              before { get :index, params: { klass: kind } }

              it do
                expect(response.content_type).to eq 'text/html; charset=utf-8'
                expect(response).to have_http_status :success
              end
            end

            describe 'json' do
              before { get :index, params: { klass: kind }, format: 'json' }

              it do
                expect(response.content_type).to eq 'application/json; charset=utf-8'
                expect(response).to have_http_status :success
              end
            end
          end

          if kind == 'anime'
            describe '#season' do
              describe 'html' do
                before { get :index, params: { klass: kind, season: 'summer_2012' } }

                it do
                  expect(response.content_type).to eq 'text/html; charset=utf-8'
                  expect(response).to have_http_status :success
                end
              end

              describe 'json' do
                before { get :index, params: { klass: kind, season: 'summer_2012' }, format: 'json' }

                it do
                  expect(response.content_type).to eq 'application/json; charset=utf-8'
                  expect(response).to have_http_status :success
                end
              end
            end
          end
        end
      end

      describe '#autocomplete' do
        let(:entry) { build_stubbed kind }
        let(:phrase) { 'qqq' }

        before do
          allow("Autocomplete::#{kind.classify}".constantize)
            .to receive(:call)
            .and_return [entry]
        end
        subject! { get :autocomplete, params: { search: 'Fff', klass: kind }, xhr: true }

        it do
          expect(collection).to eq [entry]
          expect(response.content_type).to eq 'application/json; charset=utf-8'
          expect(response).to have_http_status :success
        end
      end

      describe '#autocomplete_v2' do
        let(:entry) { build_stubbed kind }
        let(:phrase) { 'qqq' }

        before do
          allow("Autocomplete::#{kind.classify}".constantize)
            .to receive(:call)
            .and_return [entry]
        end
        subject! { get :autocomplete_v2, params: { search: 'Fff', klass: kind }, xhr: true }

        it do
          expect(collection).to eq [entry]
          expect(response.content_type).to eq 'text/html; charset=utf-8'
          expect(response).to have_http_status :success
        end
      end
    end
  end
end
