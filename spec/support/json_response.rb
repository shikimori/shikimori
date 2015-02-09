module JsonResponse
  def json
    @json ||= data
  end

private

  def data
    data = JSON.parse(response.body)
    sym_keys data
  end

  def sym_keys data
    if data.kind_of?(Hash)
      data.symbolize_keys
    elsif data.kind_of?(Array)
      data.map { |d| sym_keys d }
    else
      data
    end
  end
end
