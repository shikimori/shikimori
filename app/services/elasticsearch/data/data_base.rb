class Elasticsearch::Data::DataBase
  method_object :entry

  def call
    self.class::FIELDS.each_with_object({}) do |name, memo|
      memo[name] = send name
    end
  end

private

  def fix name
    name&.downcase
  end
end
