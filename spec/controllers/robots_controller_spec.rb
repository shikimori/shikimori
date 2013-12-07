require 'spec_helper'

describe RobotsController do
  describe :animeonline do
    before { get :animeonline }
    it { should respond_with :success }
    it { should respond_with_content_type :text }
  end

  describe :shikimori do
    before { get :shikimori }
    it { should respond_with :success }
    it { should respond_with_content_type :text }
  end
end
