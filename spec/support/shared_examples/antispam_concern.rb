shared_examples :antispam_concern do |type|
  describe 'antispam concern' do
    it { expect(type.to_s.classify.constantize.antispam_options).to be_present }
  end
end
