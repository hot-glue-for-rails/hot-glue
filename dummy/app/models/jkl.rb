class Jkl < ApplicationRecord
  belongs_to :hgi


  enum genres: {
    Fiction: "Fiction",
    Nonfiction: "Nonfiction",
    Mystery: "Mystery",
    Romance: "Romance",
    Mystery: "Mystery"
  }
end
