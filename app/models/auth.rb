class Auth < ApplicationRecord
	#include ImageUrl
	include Imageable

	
	PERMIT_COLUMNS = [:description, :authable_type, :authable_id, :status, images_attributes: [:id, :image, :imagable_type, :imagable_id, :_destroy]]

  belongs_to :authable, polymorphic: true, optional: true

  enum status: %i(rejected confirm)
  ransacker :status, formatter: proc {|v| statuses[v]}

	delegate :targets, to: :authable, allow_nil: true
	before_create :check_user_auth

	private 

	def check_user_auth
		throw(:abort) if (self.authable.auths.present? && self.authable_type == "User")
	end
end
