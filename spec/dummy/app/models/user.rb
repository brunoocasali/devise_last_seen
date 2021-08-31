class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :lastseenable, stretches: 13

  validates :name, presence: true
end
