class Project < ApplicationRecord
	include ImageUrl
	include Imageable

	PERMIT_COLUMNS = [:experience_period, :description, :deposit, :image]
	
  belongs_to :tutor, optional: true
	has_many :project_tutees, dependent: :nullify
end
