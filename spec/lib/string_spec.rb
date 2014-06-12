require 'spec_helper'

describe String do
  subject { 'тЕст' }

  its(:capitalize) { should eq 'Тест' }
  its(:downcase) { should eq 'тест' }
end
