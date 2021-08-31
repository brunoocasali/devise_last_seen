class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :lastseenable, stretches: 13

  def valid_password?(*_args)
    true
  end
end
