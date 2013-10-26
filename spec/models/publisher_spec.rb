
require 'spec_helper'

describe Publisher do
  it { should have_and_belong_to_many :mangas }
end
