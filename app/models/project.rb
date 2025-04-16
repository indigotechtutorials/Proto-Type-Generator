class Project < ApplicationRecord
  has_many :code_iterations, dependent: :destroy
end
