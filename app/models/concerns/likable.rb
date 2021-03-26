module Likable
	extend ActiveSupport::Concern
	
	included do
		has_many :likes, as: :likable, dependent: :destroy

		def is_liked? user
			likes.exists?(user: user)
		end
	end

end
	