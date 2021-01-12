class ListImports::ListEntry
  include ShallowAttributes

  TargetType = Types::Strict::String.enum('Anime', 'Manga')

  attribute :target_title, String,
    default: ->(object, _attribute) { "ID=#{object.target_id}" }
  attribute :target_id, Integer
  attribute :target_type, TargetType

  attribute :score, Integer, default: 0

  attribute :status, Types::UserRate::Status

  attribute :rewatches, Integer, default: 0

  attribute :episodes, Integer, default: 0
  attribute :volumes, Integer, default: 0
  attribute :chapters, Integer, default: 0

  attribute :text, String, default: ''

  def self.build user_rate
    new(
      target_title: user_rate.target&.name,
      target_id: user_rate.target_id,
      target_type: user_rate.target_type,
      score: user_rate.score,
      status: user_rate.status,
      rewatches: user_rate.rewatches,
      episodes: user_rate.episodes,
      volumes: user_rate.volumes,
      chapters: user_rate.chapters,
      text: user_rate.text
    )
  end

  def export user_rate
    return unless user_rate.target

    export_fields user_rate
    export_text user_rate

    %i[episodes volumes chapters].each do |counter|
      export_counter user_rate, counter if user_rate.target.respond_to? counter
    end

    user_rate
  end

  def anime?
    target_type == TargetType[Anime.name]
  end

private

  def export_fields user_rate
    user_rate.status = status
    user_rate.score = score
    user_rate.rewatches = rewatches
  end

  def export_text user_rate
    fixed_text = text&.gsub(%r{<br ?/?>}, "\n")&.strip
    user_rate.text = fixed_text if fixed_text.present?
  end

  def export_counter user_rate, counter
    user_rate[counter] = send(counter)

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
