module HotGlueHelper

  def enum_to_collection_select(hash)
    hash.collect{|k,v| OpenStruct.new({key: k, value: v})}

  end

end
