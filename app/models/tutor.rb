class Tutor < User
	include Authable

	has_many :projects, dependent: :destroy
	has_many :attendances, through: :projects

	has_many :options
	has_many :chapters, through: :options

  def targets
    self.auths.includes(:images).first.images.first
  end

end
