class Provincia < ApplicationRecord
  has_many :cantones, dependent: :restrict_with_error

  normalizes :nombre, with: ->(nombre) { nombre.strip }

  validates :codigo, presence: true, uniqueness: true,
                     inclusion: { in: ("01".."24").to_a, allow_blank: true }
  validates :nombre, presence: true, uniqueness: { case_sensitive: false }
end
