class UUIDField < AssociationField
  def spec_setup_let_arg
    "#{name.to_s.gsub('_id','')}: #{name.to_s.gsub('_id','')}1"
  end

  def spec_list_view_assertion
    assoc_name = name.to_s.gsub('_id','')
    association = eval("#{singular_class}.reflect_on_association(:#{assoc_name})")
    "expect(page).to have_content(#{singular}#{1}.#{assoc_name}.#{HotGlue.derrive_reference_name(association.class_name)})"
  end
end
