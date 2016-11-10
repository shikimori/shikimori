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
    return model.description_en if model.description_en =~ /\[source\]/
    klass_name = model.class.name.downcase
    mal_url = "http://myanimelist.net/#{klass_name}/#{model.id}"
    "#{model.description_en}[source]#{mal_url}[/source]"
  end
end
