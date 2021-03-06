# frozen_string_literal: true

# @restful_api 1.0
#
# @property email [String]
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :topics
  has_many :candidates
  has_many :votes

  validates :email, presence: true, uniqueness: true
  validates_presence_of :password, on: :create
  validates_length_of :password, minimum: 8, allow_blank: true
end
