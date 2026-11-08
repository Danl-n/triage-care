class HospitalReferencia < ApplicationRecord
  belongs_to :tipo_red

  normalizes :nombre, with: ->(nombre) { nombre.strip }

  validates :nombre, presence: true, uniqueness: { case_sensitive: false }
  validates :telefono, format: { with: /\A[0-9 +()-]{7,20}\z/, allow_blank: true }
end
