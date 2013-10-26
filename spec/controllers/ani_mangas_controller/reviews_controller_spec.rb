require 'spec_helper'

describe AniMangasController::ReviewsController do
  [:anime, :manga].each do |kind|
    describe kind do
      before { create :section, id: AniMangaEntry::SectionIDs[kind.to_s.capitalize], permalink: 'a', name: 'Аниме' }

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
          text: "reviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtext reviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtext reviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtext reviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtext reviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtext reviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtext reviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtext reviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtext reviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtext reviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtext reviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtextreviewtext",
          storyline: 1,
          characters: 1,
          animation: 1,
          music: 1,
          overall: 1
        }
      end

      describe :show do
        describe "success" do
          before { review }

          it "html" do
            get :show, defaults.merge(id: review.id)
            should respond_with 200
            response.body.should include(review.text)
          end

          it "json" do
            get :show, defaults.merge(id: review.id, format: 'json')
            should respond_with 200
          end
        end
      end

      describe :index do
        describe "success" do
          before { review }

          it "html" do
            get :index, defaults
            should respond_with 200
            response.body.should include(review.text)
          end

          it "json" do
            get :index, defaults.merge(format: 'json')
            response.should be_success
          end

          it 'with id' do
            get :index, defaults.merge(id: review.id)
            should respond_with 200
            response.body.should include(review.text)
          end
        end
      end

      describe :new do
        it "not authorized" do
          get :new, defaults
          should respond_with 302
        end

        describe "success" do
          before { sign_in user }

          it "html" do
            get :new, defaults
            should respond_with 200
          end

          it "json" do
            get :new, defaults.merge(format: 'json')
            should respond_with 200
          end
        end
      end

      describe :edit do
        it "not authorized" do
          get :edit, defaults.merge(id: review.id)
          should respond_with 302
        end

        describe "success" do
          before { sign_in user }

          it "html" do
            get :edit, defaults.merge(id: review.id)
            should respond_with 200
          end

          it "json" do
            get :edit, defaults.merge(id: review.id, format: 'json')
            should respond_with 200
          end
        end
      end

      describe :update do
        it "forbidden" do
          put :update, defaults.merge(id: review.id)
          should respond_with 302
        end

        describe 'sign_in user' do
          before { sign_in user and review }

          describe 'creator' do
            it 'success' do
              expect {
                put :update, defaults.merge(id: review.id, review: valid_hash)
              }.to change(Review, :count).by(0)

              Review.find(review.id).text.should == valid_hash[:text]

              should respond_with 200
            end
          end

          describe 'random user' do
            it 'forbidden' do
              review2 = create :review, user: create(:user)

              put :update, defaults.merge(id: review2.id, review: valid_hash)
              Review.find(review2.id).text.should == review2.text

              response.should be_forbidden
            end
          end

          it 'bad params' do
            expect {
              put :update, defaults.merge(id: review.id, review: { text: nil })
            }.to change(Review, :count).by(0)
            response.should be_unprocessible_entiy
          end
        end
      end

      describe :destroy do
        it "not authorized" do
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

              response.should be_forbidden
            end
          end
        end
      end

      describe :create do
        it "not authorized" do
          post :create, defaults
          should respond_with 302
        end

        describe 'sign_in user' do
          before { sign_in user }

          it 'bad params' do
            expect {
              post :create, defaults.merge(review: {})
            }.to change(Review, :count).by 0

            response.should be_unprocessible_entiy
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
