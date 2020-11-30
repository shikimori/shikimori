describe DbStatistics::ListSize do
  subject { described_class.call scope, interval }
  let(:scope) { UserRate.where(target_type: 'Manga') }
  let(:interval) { described_class::Interval[:long] }

  10.times do |i|
    let!(:"manga_#{i}") { create :manga }
  end

  10.times do |i|
    let!(:"manga_rate_#{i}") do
      create :user_rate, :completed, user: user, target: send(:"manga_#{i}")
    end
  end

  it do
    is_expected.to have(described_class::INTERVALS[interval].size).keys
    expect(subject['10']).to eq 1
    expect(subject.values[1..].all?(&:zero?)).to eq true
  end

  context 'user is excluded' do
    let(:user) do
      create :user,
        roles: [Types::User::ROLES_EXCLUDED_FROM_STATISTICS.sample]
    end

    it do
      is_expected.to have(described_class::INTERVALS[interval].size).keys
      expect(subject.values.all?(&:zero?)).to eq true
    end
  end
end
