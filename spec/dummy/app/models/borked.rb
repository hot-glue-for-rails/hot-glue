class Borked < ApplicationRecord

  # this table is intentionally missing belongs_to :xyz
  #

  # this tbale
  belongs_to :missing_label_table
end
