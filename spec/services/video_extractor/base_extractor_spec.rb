require 'spec_helper'

describe VideoExtractor::BaseExtractor do
  let(:service) { VideoExtractor::BaseExtractor.new 'test' }

  describe :hosting do
    subject { service.hosting }
    it { should eq :base }
  end
end
