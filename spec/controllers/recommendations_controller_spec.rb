require 'spec_helper'

describe RecommendationsController do
  ['anime', 'manga'].each do |type|
    describe 'index' do
      before { get :index, klass: type, metric: 'pearson', threshold: 45 }
      it { should respond_with 200 }
      it { should respond_with_content_type :html }
    end

    describe 'index witout params' do
      before { get :index, klass: type }
      it { should respond_with 302 }
    end
  end
end
