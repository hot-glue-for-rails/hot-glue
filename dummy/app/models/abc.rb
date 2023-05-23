class Abc < ApplicationRecord
  @@table_label_plural = "Apples"
  @@table_label_singular = "Apple"

  has_one_attached :aaa

  has_one_attached :bbb do |attachable|
    attachable.variant :thumb, resize_to_limit: [100,100]
  end
end
