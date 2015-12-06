describe SimilarUsersService do
  let(:service) { SimilarUsersService.new user, Anime, 50 }

  let(:user) { create :user }
  let(:user1) { create :user }
  let(:user2) { create :user }
  let(:user3) { create :user }

  before do
    allow(service).to receive(:similarities).and_return [
      [user1.id, 0.2],
      [user2.id, 0.7],
      [user3.id, 0.4]
    ]
  end

  it { expect(service.fetch).to eq [user2.id, user3.id, user1.id] }
end
