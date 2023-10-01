class Jkl < ApplicationRecord
  belongs_to :hgi

  enum genre: {
    Fiction: "Fiction",
    Nonfiction: "Nonfiction",
    Mystery: "Mystery",
    Romance: "Romance",
  }
end
