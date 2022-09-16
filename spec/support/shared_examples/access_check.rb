shared_examples :has_access do
  before { subject }

  it 'has_access' do
    expect(response).to have_http_status :success
    expect(resource).to_not be_kind_of NullObject
  end
end

shared_examples :has_no_access do |is_nil_object_when_no_access|
  it 'has_no_access' do
    if is_nil_object_when_no_access
      expect(response).to have_http_status :success
      expect(resource).to be_kind_of NullObject
    else
      expect { subject }.to raise_error CanCan::AccessDenied
    end
  end
end
