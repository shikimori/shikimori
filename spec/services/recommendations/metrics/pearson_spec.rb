describe Recommendations::Metrics::Pearson do
  let(:metric) { Recommendations::Metrics::Pearson.new }

  describe '#compare' do
    let(:minimun_shared) { 1 }

    before { stub_const 'Recommendations::Metrics::Pearson::MINIMUM_SHARED', minimun_shared }
    subject { metric.compare :user_1, user_1_rates, :user_2, user_2_rates }

    describe 'minimum_shared' do
      let(:user_1_rates) { { a: 1, b: 2, c: 3 } }
      let(:user_2_rates) { user_1_rates }
      let(:minimun_shared) { 10 }

      it { is_expected.to eq 0 }
    end

    describe 'equal sets' do
      let(:user_1_rates) { { a: 1, b: 2, c: 3 } }
      let(:user_2_rates) { user_1_rates }

      it { is_expected.to eq 1 }
    end

    describe 'different sets' do
      let(:user_1_rates) { { a: 6, b: 6, c: 6, d: 7, e: 7, f: 7, g: 8, h: 8 } }
      let(:user_2_rates) { { a: 6, b: 6, c: 6, d: 7, e: 7, f: 7, g: 8, h: 6 } }

      # http://www.socscistatistics.com/tests/pearson/Default2.aspx
      it { is_expected.to eq 0.6039571739702033 }
    end

    describe 'z score' do
      let(:all_rates) do
        {
          user_1: {
            sample_1: 1,
            sample_2: 3,
            sample_3: 6
          },
          user_2: {
            sample_1: 3,
            sample_2: 6,
            sample_3: 9
          }
        }
      end
      let(:normalization) { Recommendations::Normalizations::ZScore.new }
      let(:user_1_rates) { normalization.normalize all_rates[:user_1], :user_1 }
      let(:user_2_rates) { normalization.normalize all_rates[:user_1], :user_1 }

      it { is_expected.to eq 1 }
    end
  end
end
