describe ReviewsController do
  [:anime, :manga].each do |kind|
    describe kind.to_s do
      before { create :section, id: DbEntryThread::SectionIDs[kind.to_s.capitalize], permalink: 'a', name: 'Аниме' }

      let(:user) { create :user }
      let(:entry) { create kind }
      let(:review) { create :review, user_id: user.id, target_id: entry.id, target_type: entry.class.name }

      let(:defaults) do
        {
          "#{kind}_id" => entry.to_param,
          type: entry.class.name
        }
      end

      let(:valid_hash) do
        {
          text: 1188.times.sum {|v| 's' },
          storyline: 1,
          characters: 1,
          animation: 1,
          music: 1,
          overall: 1
        }
      end

      describe '#show' do
        describe 'success' do
          before { review }

          it 'html' do
            get :show, defaults.merge(id: review.id)
            should respond_with 200
            expect(response.body).to include(review.text)
          end

          it 'json' do
            get :show, defaults.merge(id: review.id, format: 'json')
            should respond_with 200
          end
        end
      end

      describe '#index' do
        describe 'success' do
          before { review }

          it 'html' do
            get :index, defaults
            should respond_with 200
            expect(response.body).to include(review.text)
          end

          it 'json' do
            get :index, defaults.merge(format: 'json')
            expect(response).to be_success
          end

          it 'with id' do
            get :index, defaults.merge(id: review.id)
            should respond_with 200
            expect(response.body).to include(review.text)
          end
        end
      end

      describe '#new' do
        it 'not authorized' do
          get :new, defaults
          should respond_with 302
        end

        describe 'success' do
          before { sign_in user }

          it 'html' do
            get :new, defaults
            should respond_with 200
          end

          it "json" do
            get :new, defaults.merge(format: 'json')
            should respond_with 200
          end
        end
      end

      describe '#edit' do
        it 'not authorized' do
          get :edit, defaults.merge(id: review.id)
          should respond_with 302
        end

        describe 'success' do
          before { sign_in user }

          it 'html' do
            get :edit, defaults.merge(id: review.id)
            should respond_with 200
          end

          it 'json' do
            get :edit, defaults.merge(id: review.id, format: 'json')
            should respond_with 200
          end
        end
      end

      describe 'update' do
        it 'forbidden' do
          patch :update, defaults.merge(id: review.id)
          should respond_with 302
        end

        describe 'sign_in user' do
          before { sign_in user and review }

          describe 'creator' do
            it 'success' do
              expect {
                patch :update, defaults.merge(id: review.id, review: valid_hash)
              }.to change(Review, :count).by(0)

              expect(Review.find(review.id).text).to eq(valid_hash[:text])

              should respond_with 200
            end
          end

          describe 'random user' do
            it 'forbidden' do
              review2 = create :review, user: create(:user)

              patch :update, defaults.merge(id: review2.id, review: valid_hash)
              expect(Review.find(review2.id).text).to eq(review2.text)

              expect(response).to be_forbidden
            end
          end

          it 'bad params' do
            expect {
              patch :update, defaults.merge(id: review.id, review: { text: nil })
            }.to change(Review, :count).by(0)
            expect(response).to be_unprocessible_entiy
          end
        end
      end

      describe 'destroy' do
        it 'not authorized' do
          delete :destroy, defaults.merge(id: review.id)
          should respond_with 302
        end

        describe 'sign_in user' do
          before { sign_in user and review }

          describe 'creator' do
            it 'success' do
              expect {
                delete :destroy, defaults.merge(id: review.id)
              }.to change(Review, :count).by(-1)
              should respond_with 200
            end
          end

          describe 'random user' do
            it 'forbidden' do
              review2 =  create :review, user: create(:user)

              expect {
                delete :destroy, defaults.merge(id: review2.id)
              }.to change(Review, :count).by(0)

              expect(response).to be_forbidden
            end
          end
        end
      end

      describe 'create' do
        it 'not authorized' do
          post :create, defaults
          should respond_with 302
        end

        describe 'sign_in user' do
          before { sign_in user }

          it 'bad params' do
            expect {
              post :create, defaults.merge(review: { text: 'test'})
            }.to change(Review, :count).by 0

            should respond_with 422
          end

          it 'success' do
            expect {
              post :create, defaults.merge(review: valid_hash)
            }.to change(Review, :count).by 1

            should respond_with 200
          end
        end
      end
    end
  end
end
