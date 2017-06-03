class Elasticsearch::Data::DataBase
  extend DslAttribute

  method_object :entry

  dsl_attribute :text_search_fields
  dsl_attribute :data_fields
  dsl_attribute :track_changes_fields

  def call
    (text_search_fields + data_fields).each_with_object({}) do |name, memo|
      memo[name] = send name
    end
  end

private

  def fix name
    name&.downcase
  end
end
