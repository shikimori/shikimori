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
    klass.find_each.with_index(1) do |model, index|
      model.description_ru = new_description_ru(model)
      model.description_en = new_description_en(model)
      model.save!

      puts "#{index} descriptions updated" if index % 5_000 == 0
    end
  end

  def new_description_ru model
    return model.description_ru if model.description_ru =~ /\[source\]/
    "#{model.description_ru}[source]#{model.source}[/source]"
  end

  def new_description_en model
    value = model.description_en
    type = model.class.name.downcase
    Mal::ProcessDescription.new.(value, type, model.id)
  end
end
