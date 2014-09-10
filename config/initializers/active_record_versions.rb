class ActiveRecord::Base
  module ClassMethod
    def diff(*attrs)
      self.diff_attrs = attrs
    end
  end

  class_attribute :diff_attrs

  def moderated_update params, current_user=nil
    diff_hash = diff params
    create_version(diff_hash, current_user) unless diff_hash.blank?
    update params
  end

  def diff(other_record = nil)
    if other_record.nil?
      old_record, new_record = self.class.find(id), self
    else
      old_record, new_record = self, other_record
    end

    if new_record.is_a?(Hash)
      diff_each(new_record) do |(attr_name, hash_value)|
        [attr_name, old_record.send(attr_name), hash_value]
      end
    else
      attrs = self.class.diff_attrs

      if attrs.nil?
        attrs = self.class.content_columns.map { |column| column.name.to_sym }
      elsif attrs.length == 1 && Hash === attrs.first
        columns = self.class.content_columns.map { |column| column.name.to_sym }

        attrs = columns + (attrs.first[:include] || []) - (attrs.first[:exclude] || [])
      end

      diff_each(attrs) do |attr_name|
        [attr_name, old_record.send(attr_name), new_record.send(attr_name)]
      end
    end
  end

  def versions
    Version.where(item_id: self.id, item_type: self.class.name).order('id desc')
  end

private
  def diff_each(enum)
    enum.inject({}) do |diff_hash, attr_name|
      attr_name, old_value, new_value = *yield(attr_name)

      unless old_value === new_value
        diff_hash[attr_name.to_sym] = [old_value, new_value]
      end

      diff_hash
    end
  end

  def create_version diff_hash, current_user
    Version.create(
      item_type: self.class.name,
      item_id: id,
      user_id: current_user.try(:id),
      state: :accepted_pending,
      item_diff: diff_hash.to_s,
    )
  end
end
