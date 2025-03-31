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
end
