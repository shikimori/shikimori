describe BanDuration do
  describe :to_s do
    subject { BanDuration.new(duration).to_s }

    describe :nothing do
      let(:duration) { 0 }
      it { should eq '0m' }
    end

    describe :minutes do
      let(:duration) { 30 }
      it { should eq '30m' }
    end

    describe :hours do
      let(:duration) { 60*2 }
      it { should eq '2h' }
    end

    describe :days do
      let(:duration) { 60*24*3 }
      it { should eq '3d' }
    end

    describe :weeks do
      let(:duration) { 60*24*7*2 }
      it { should eq '2w' }
    end

    describe :mixed do
      let(:duration) { 60*24*7*8 + 60*24*3 + 60*4 + 15 }
      it { should eq '8w 3d 4h 15m' }
    end
  end

  describe :to_i do
    subject { BanDuration.new(duration).to_i }

    describe :minutes do
      let(:duration) { '30m' }
      it { should eq 30 }
    end

    describe :hours do
      let(:duration) { '1.5h' }
      it { should eq 60*1.5 }
    end

    describe :days do
      let(:duration) { '40d' }
      it { should eq 60*24*40 }
    end

    describe :weeks do
      let(:duration) { '3w' }
      it { should eq 60*24*7*3 }
    end

    describe :mixed do
      let(:duration) { '3w 2h 5d 1m' }
      it { should eq 60*24*7*3 + 60*24*5 + 60*2 + 1 }
    end
  end

  describe :humanize do
    subject { BanDuration.new(duration).humanize }

    describe :minutes do
      let(:duration) { '33m' }
      it { should eq '33 минуты' }
    end

    describe :hours do
      let(:duration) { '1.5h' }
      it { should eq '1 час 30 минут' }
    end

    describe :days do
      let(:duration) { '6d' }
      it { should eq '6 дней' }
    end

    describe :weeks do
      let(:duration) { '3w' }
      it { should eq '3 недели' }
    end

    describe :mixed do
      let(:duration) { '3w 2h 5d 1m' }
      it { should eq '3 недели 5 дней' }
    end

    describe :mixed_with_zero do
      let(:duration) { '3w 5h 1m' }
      it { should eq '3 недели' }
    end
  end
end
