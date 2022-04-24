class Versions::CollectionVersion < Version
  def current_value association_name
    item
      .send(association_name)
      .map do |entry|
        JSON.parse(entry.attributes.except('id').to_json)
      end
  end

  def apply_changes
    item_diff.each do |(association, (_old_collection, new_collection))|
      # will fail with "delete_all" on apply of external_link version
      item.send(association).destroy_all
      import_collection association, new_collection

      # no need to add external_links into desynced
      # add_desynced association
    end

    if item.changed?
      item.save
    else
      item.touch
    end
  end

  def rollback_changes
    item_diff.each do |(association, (old_collection, _new_collection))|
      # will fail with "delete_all" on rollback of external_link version
      item.send(association).destroy_all
      import_collection association, old_collection
    end
    item.touch
  end

private

  def import_collection association, collection
    klass = association.classify.constantize
    models = collection.map { |item| klass.new fix(item) }

    klass.import models, on_duplicate_key_ignore: true
  end

  def fix hash
    hash.each_with_object({}) do |(key, value), memo|
      next if key == 'id'
      next if value.blank?

      memo[key] =
        if key.match?(/^[\w_]+_at$/) && value.present?
          Time.zone.parse(value)
        else
          value
        end
    end
  end
end
