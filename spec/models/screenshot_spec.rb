require 'spec_helper'

describe Screenshot do
  context '#relations' do
    it { should belong_to :anime }
  end

  context '#validations' do
    #it { should validate_presence_of :anime }
    it { should validate_presence_of :url }
    it { should validate_attachment_presence :image }
  end
end
