require 'spec_helper'

describe CommentView do
  it { should belong_to :user }
  it { should belong_to :comment }
end
