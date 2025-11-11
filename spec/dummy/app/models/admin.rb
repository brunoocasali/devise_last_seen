class Admin < ApplicationRecord
  devise :database_authenticatable, :registerable, stretches: 1
end
