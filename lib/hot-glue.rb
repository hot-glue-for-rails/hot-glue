require "hotglue/engine"
require 'kaminari'

module HotGlue
  module TemplateBuilders

  end


  class Error < StandardError
  end


  def self.to_camel_case(str)
    words = str.split(/[^a-zA-Z0-9]/) # split by non-alphanumeric characters
    return '' if words.empty?

    first_word = words.first.downcase
    rest_words = words[1..-1].map { |w| w.capitalize }

    first_word + rest_words.join
  end


  def self.optionalized_ternary(namespace: nil,
                                target:,
                                nested_set:,
                                prefix: nil, # is this used
                                modifier: "",
                                with_params: false,
                                top_level: false,
                                put_form: false,
                                instance_last_item: false )
    instance_sym = top_level ? "@" : ""


    if nested_set.nil? || nested_set.empty?
      return modifier + "#{(namespace + '_') if namespace}#{target}_path" + (("(#{instance_sym}#{target})" if put_form) || "")
    elsif nested_set[0][:optional] == false

      res = modifier + ((namespace + "_" if namespace) || "") + nested_set.collect{|x|
        x[:singular] + "_"
      }.join() + target + "_path" + (("(#{nested_set.collect{
        |x| instance_sym + x[:singular] }.join(",")
      }#{ put_form ? ',' + (instance_last_item ? "@" : instance_sym) + target : '' })") || "")

      res

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

      # is_missing_path = HotGlue.optionalized_ternary(
      #   namespace: namespace,
      #   target: target,
      #   modifier: modifier,
      #   top_level: top_level,
      #   with_params: with_params,
      #   put_form: put_form,
      #   nested_set: rest_of_nest  )
      #
      return "#{is_present_path}"
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

