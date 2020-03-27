# frozen_string_literal: true

module SortingConcern
  extend ActiveSupport::Concern

  included do
    SORTING_FIELD = :id
    SORTING_ORDER = :desc

    helper_method :sorting_2_defaults
    helper_method :sorting_field
    helper_method :sorting_order
    helper_method :th
  end

  def sorting_options type = resource_type_sym
    if sorting_field_2
      [
        build_sort(sorting_field(type), sorting_order(type)),
        build_sort(sorting_field_2, sorting_order_2)
      ]
    elsif !params[:sorting_field] && self.class.const_defined?('SORTING_FIELDS')
      self.class::SORTING_FIELDS
    else
      [
        build_sort(sorting_field(type), sorting_order(type))
      ]
    end
  end

  def sorting_2_defaults type = resource_type_sym
    {
      default_sorting_field(type) => default_sorting_order(type)
    }
  end

  def sorting_field type = resource_type_sym
    if params[:sort_field].present?
      params[:sort_field].to_sym
    else
      default_sorting_field(type)
    end
  end

  def sorting_order type = resource_type_sym
    if params[:sort_order].present?
      params[:sort_order].to_sym
    else
      default_sorting_order(type)
    end
  end

  def sorting_field_2
    if params[:sort_field_2].present?
      params[:sort_field_2].to_sym
    end
  end

  def sorting_order_2
    if params[:sort_order_2].present?
      params[:sort_order_2].to_sym
    end
  end

  def resource_class
    self.class.name.gsub(/.*::|Controller$/, '').singularize.constantize
  end

  def resource_type_sym
    resource_class.name.underscore.to_sym
  end

  def default_sorting_field type = resource_type_sym
    "Moderations::#{type.to_s.classify.pluralize}Controller::SORTING_FIELD".constantize
  end

  def default_sorting_order type = resource_type_sym
    "Moderations::#{type.to_s.classify.pluralize}Controller::SORTING_ORDER".constantize
  end

  def build_sort field, order
    if field.to_s.include? '.'
      parts = field.to_s.match(/(.*?)\.(.*)/)
      parts[1].classify.constantize.arel_table[parts[2]].send(order)
    else
      resource_class.arel_table[field].send(order)
    end
  end

  def th( # rubocop:disable Metrics/ParameterLists
    label: nil,
    field: nil,
    default_order: :asc,
    colspan: nil,
    width: 'auto',
    sort_2: field && field != default_sorting_field ?
      sorting_2_defaults :
      {}
  )
    render_to_string(
      partial: 'support/th',
      locals: {
        label: label || resource_class.human_attribute_name(field),
        field: field&.to_sym,
        default_order: default_order,
        colspan: colspan,
        width: width,
        sort_2: sort_2
      }
    )
  end
end
