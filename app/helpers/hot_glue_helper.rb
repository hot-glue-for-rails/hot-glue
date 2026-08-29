module HotGlueHelper
  class KVObject
    attr_accessor :key, :value
    def initialize(key: , value: )
      @key = key
      @value = value
    end
  end

  def enum_to_collection_select(hash)
    hash.collect{|k,v| KVObject.new(key: k, value: v)}
  end

  def sort_link(field, label)
    field = field.to_s
    active = params[:sort] == field
    direction = active ? params[:direction] : nil

    next_direction =
      if !active
        'asc'
      elsif direction == 'asc'
        'desc'
      else
        nil
      end

    new_params = request.query_parameters.except('sort', 'direction', 'page')
    if next_direction
      new_params['sort'] = field
      new_params['direction'] = next_direction
    end

    arrow =
      if active && direction == 'asc'
        '&nbsp;&#9650;'
      elsif active && direction == 'desc'
        '&nbsp;&#9660;'
      else
        ''
      end

    link_to (label + arrow).html_safe, "#{request.path}?#{new_params.to_query}".chomp('?'), style: 'white-space: nowrap', 'data-turbo-action': 'advance'
  end
end
