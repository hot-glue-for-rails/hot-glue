class Jkl < ApplicationRecord
  belongs_to :hgi


  enum genres: {
    fiction: "Fiction",
    nonfiction: "Nonfiction",
    biography: "Biography",
    science_fiction: "Science fiction",
    mystery: "Mystery"
  }
end
