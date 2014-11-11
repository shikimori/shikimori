class NoAntispam < ActiveRecord::Base; include Antispam; end
NoAntispam.antispam = false
class WithAntispam < ActiveRecord::Base; include Antispam; end

describe Antispam do
  it 'antispam?' do
    WithAntispam.with_antispam?.should be_true
    NoAntispam.with_antispam?.should be_false
  end

  describe Comment do
    let(:user) { build_stubbed :user }
    let(:topic) { build_stubbed :topic }

    it 'works' do
      create :comment, :with_antispam, user: user, commentable: topic

      expect {
        lambda {
          create :comment, :with_antispam, user: user, commentable: topic
        }.should raise_error ActiveRecord::RecordNotSaved
      }.to_not change Comment, :count
    end

    it 'can be disabled' do
      create :comment, :with_antispam, user: user, commentable: topic

      expect {
        Comment.wo_antispam do
          create :comment, :with_antispam, user: user, commentable: topic
        end
      }.to change(Comment, :count).by 1
    end
  end
end
