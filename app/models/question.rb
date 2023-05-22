class Question < ApplicationRecord
  has_many :options, dependent: :destroy
end
