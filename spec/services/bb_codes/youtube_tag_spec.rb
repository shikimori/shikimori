require 'spec_helper'

describe BbCodes::YoutubeTag do
  let(:tag) { BbCodes::YoutubeTag.instance }
  subject { tag.format text }

  describe :format do
    let(:hash) { 'og2a5lngYeQ' }

    context 'with time' do
      let(:time) { 22 }
      let(:text) { "https://www.youtube.com/watch?v=#{hash}#t=#{time}" }
      it { should include "<div class=\"image-container video youtube\"" }
      it { should include "a data-href=\"http://youtube.com/v/#{hash}?start=#{time}\" href=\"http://youtube.com/watch?v=#{hash}#t=#{time}\"" }
    end

    context 'without time' do
      let(:text) { "https://www.youtube.com/watch?v=#{hash}" }
      it { should include "<div class=\"image-container video youtube\"" }
      it { should include "a data-href=\"http://youtube.com/v/#{hash}\" href=\"http://youtube.com/watch?v=#{hash}\"" }
    end

    context 'with text' do
      let(:text) { "zzz https://www.youtube.com/watch?v=#{hash}" }
      it { should include "zzz <div class=\"image-container video youtube\"" }
      it { should include "a data-href=\"http://youtube.com/v/#{hash}\" href=\"http://youtube.com/watch?v=#{hash}\"" }
    end
  end
end
