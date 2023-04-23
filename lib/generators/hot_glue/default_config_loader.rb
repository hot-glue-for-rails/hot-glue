module DefaultConfigLoader


  def default_configs
    @yaml_from_config ||= YAML.load(File.read("config/hot_glue.yml"))
  end


  def  get_default_from_config(key: )
    default_configs[key]
  end
end
