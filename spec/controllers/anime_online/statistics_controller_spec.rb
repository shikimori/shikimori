require 'spec_helper'

describe AnimeOnline::StatisticsController do
  describe :uploaders do
    before do
      get :uploaders
    end

    it { should respond_with_content_type :html }
    it { response.should be_success }
  end
end
