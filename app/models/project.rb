class Project < ApplicationRecord
	include ImageUrl
	include Imageable

	PERMIT_COLUMNS = [:experience_period, :description, :deposit, :image, :title]
	
  belongs_to :tutor, optional: true
	has_many :attendances, dependent: :nullify
	belongs_to :category
end
