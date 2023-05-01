require "hotglue/engine"
require 'kaminari'

module HotGlue
  module TemplateBuilders

  end


  class Error < StandardError
  end

  def self.construct_downnest_object(input)
    res = input.split(",").map { |child|
      child_name = child.gsub("+","")
      extra_size = child.count("+")
      {child_name => 4+extra_size}
    }
    Hash[*res.collect{|hash| hash.collect{|key,value| [key,value].flatten}.flatten}.flatten]
  end

  def self.optionalized_ternary(namespace: nil,
                                target:,
                                nested_set:,
                                modifier: "",
                                with_params: false,
                                top_level: false,
                                put_form: false)
    instance_sym = top_level ? "@" : ""

    if nested_set.nil? || nested_set.empty?
      return modifier + "#{(namespace + '_') if namespace}#{target}_path" + (("(#{instance_sym}#{target})" if put_form) || "")
    elsif nested_set[0][:optional] == false

      return modifier + ((namespace + "_" if namespace) || "") + nested_set.collect{|x|
        x[:singular] + "_"
      }.join() + target + "_path" + (("(#{nested_set.collect{
        |x| instance_sym + x[:singular] }.join(",")
      }#{ put_form ? ',' + instance_sym + target : '' })") || "")


    else
      # copy the first item, make a ternery in this cycle, and recursively move to both the
      # is present path and the is optional path

      nonoptional = nested_set[0].dup
      nonoptional[:optional] = false
      rest_of_nest = nested_set[1..-1]

      is_present_path = HotGlue.optionalized_ternary(
        namespace: namespace,
        target: target,
        modifier: modifier,
        top_level: top_level,
        with_params: with_params,
        put_form: put_form,
        nested_set: [nonoptional, *rest_of_nest])

      is_missing_path = HotGlue.optionalized_ternary(
        namespace: namespace,
        target: target,
        modifier: modifier,
        top_level: top_level,
        with_params: with_params,
        put_form: put_form,
        nested_set: rest_of_nest  )
      return "defined?(#{instance_sym + nested_set[0][:singular]}2) ? #{is_present_path} : #{is_missing_path}"
    end
  end

  def self.derrive_reference_name(thing_as_string)
    assoc_class = eval(thing_as_string)

    if assoc_class.new.respond_to?("name")
      display_column = "name"
    elsif assoc_class.new.respond_to?("to_label")
      display_column = "to_label"
    elsif assoc_class.new.respond_to?("full_name")
      display_column = "full_name"
    elsif assoc_class.new.respond_to?("display_name")
      display_column = "display_name"
    elsif assoc_class.new.respond_to?("email")
      display_column = "email"
    end
    display_column
  end


end

