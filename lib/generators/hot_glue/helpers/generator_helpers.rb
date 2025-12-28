module GeneratorHelpers

  def parent_resource_name
    @nested_set.last[:singular]
  end
end
