class AddSourceBbcodeToDescriptionFields < ActiveRecord::Migration
  def change
    update_descriptions Anime
    puts 'anime descriptions updated'
    update_descriptions Manga
    puts 'manga descriptions updated'
    update_descriptions Character
    puts 'character descriptions updated'
  end

  private

  def update_descriptions klass
    klass.find_each do |model|
      model.description_ru = new_description_ru(model)
      model.description_en = new_description_en(model)
      model.save!
    end
  end

  def new_description_ru model
    return model.description_ru if model.description_ru =~ /\[source\]/
    "#{model.description_ru}[source]#{model.source}[/source]"
  end

  def new_description_en model
    description = DbEntries::Description.new(value: model.description_en)

    current_text = description.text
    current_source = description.source

    new_source = new_description_en_source(model, description)

    "#{current_text}[source]#{new_source}[/source]"
  end

  def new_description_en_source model, description
    description.source == 'ANN' ? 'animenewsnetwork.com' : mal_url(model)
  end

  def mal_url model
    klass_name = model.class.name.downcase
    "http://myanimelist.net/#{klass_name}/#{model.id}"
  end
end
