class ListImports::ListEntry < Dry::Struct
  constructor_type :schema

  attribute :target_title, Types::Strict::String
  attribute :target_id, Types::Coercible::Int
  attribute :target_type, Types::Strict::String.enum('Anime', 'Manga')
  attribute :score, Types::Coercible::Int.default(0)
  attribute :status, Types::UserRate::Status
  attribute :rewatches, Types::Coercible::Int.default(0)
  attribute :episodes, Types::Coercible::Int.default(0)
  attribute :volumes, Types::Coercible::Int.default(0)
  attribute :chapters, Types::Coercible::Int.default(0)
  attribute :text, Types::String.default('')

  def export user_rate
    return unless user_rate.target

    export_fields user_rate
    export_text user_rate

    %i[episodes volumes chapters].each do |counter|
      export_counter user_rate, counter if user_rate.target.respond_to? counter
    end

    user_rate
  end

private

  def export_fields user_rate
    user_rate.status = @status
    user_rate.score = @score
    user_rate.rewatches = @rewatches
  end

  def export_text user_rate
    fixed_text = @text&.gsub(%r{<br ?/?>}, "\n")&.strip
    user_rate.text = fixed_text if fixed_text.present?
  end

  def export_counter user_rate, counter
    user_rate[counter] = self[counter]

    if user_rate.target[counter].positive?
      # у просмотренного выставляем число эпизодов/частей/томов равное
      # количеству у аниме/манги
      user_rate[counter] = user_rate.target[counter] if user_rate.completed?

      # нельзя указать больше/меньше эпизодов/частей/томов для просмотренного,
      # чем имеется в аниме/манге
      if user_rate[counter] > user_rate.target[counter]
        user_rate[counter] = user_rate.target[counter]
      end
    end
  end
end
