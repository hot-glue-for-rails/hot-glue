class Abc < ApplicationRecord
  after_update_commit lambda { broadcast_replace_to self, target: "__#{dom_id(self)}", partial: "/abcs/line" }
  after_destroy_commit lambda { broadcast_remove_to self, target: "__#{dom_id(self)}"}

  include ActionView::RecordIdentifier
  after_update_commit lambda { broadcast_replace_to self, target: "__#{dom_id(self)}", partial: "/abcs/line" }
  after_destroy_commit lambda { broadcast_remove_to self, target: "__#{dom_id(self)}"}


  @@table_label_plural = "Apples"
  @@table_label_singular = "Apple"
end
