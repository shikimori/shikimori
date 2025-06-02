module TopicsHelper
    def self.valid_linked linked_type
        return linked_type.blank? || Topic::LINKED_TYPES.include?(linked_type)
    end
end
