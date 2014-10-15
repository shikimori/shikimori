require 'spec_helper'

describe SpentTime do
  subject(:time) { SpentTime.new interval }

  context 'full time' do
    let(:years) { 1 }
    let(:months_6) { 1 }
    let(:months_3) { 1 }
    let(:months) { 2 }
    let(:weeks) { 3 }
    let(:days) { 4 }
    let(:hours) { 11 }

    let(:interval) { years*365 + months_6*180 + months_3*90 + months*30 + weeks*7 + days + hours / 24.0 }

    its(:years) { should eq interval / 365 }
    its(:years_part) { should eq years }

    its(:months_6) { should eq interval / 180 }
    its(:months_6_part) { should eq months_6 }

    its(:months_3) { should eq interval / 90 }
    its(:months_3_part) { should eq months_3 }

    its(:months) { should eq interval / 30 }
    its(:months_part) { should eq months }

    its(:weeks) { should eq interval / 7 }
    its(:weeks_part) { should eq weeks }

    its(:days) { should eq interval }
    its(:days_part) { should eq days }

    its(:hours) { should eq interval * 24.0 }
    its(:hours_part) { should eq hours }

    its(:minutes) { should eq interval * 24.0 * 60.0 }
  end
end
