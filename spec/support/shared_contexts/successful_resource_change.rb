shared_examples_for :successful_resource_change do |type|
  it do
    expect(resource).to be_persisted
    expect(resource).to have_attributes(params)
    expect(response).to have_http_status :success

    if type == :api
      expect(json).to_not include :html
    elsif type == :frontend
      expect(json).to include :html
    else
      raise ArgumentError, "unknown type #{type} (allowed :api or :frontend)"
    end

    expect(response.content_type).to eq 'application/json; charset=utf-8'
  end
end
