describe Votable::CleanupCheatBotVotes do
  let(:votable) { create :critique }

  before do
    Votable::Vote.call(
      votable: votable,
      voter: voter,
      vote: 'yes'
    )
  end

  subject { described_class.new.perform }

  context 'cheat_bot user' do
    let(:voter) { create :user, :cheat_bot }
    it { expect { subject }.to change(ActsAsVotable::Vote, :count).by(-1) }
  end

  context 'not cheat_bot user' do
    let(:voter) { user_1 }
    it { expect { subject }.to_not change ActsAsVotable::Vote, :count }
  end
end
