shared_examples :has_access do
  before { subject }

  it 'has_access' do
    expect(response).to have_http_status :success
  end
end

shared_examples :has_no_access do
  it 'has_no_access' do
    expect { subject }.to raise_error CanCan::AccessDenied
  end
end
