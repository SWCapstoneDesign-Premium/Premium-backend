class ProjectSerializer < Panko::Serializer
  attributes :id, :description, :deposit ,:image ,:title ,:started_at ,:duration ,:experience_period ,:category_id ,:required_time ,:review_weight ,:mission ,:book_id ,:rest, :attendance_presence, :chat, :able_start
  
	has_one :tutor, serializer: UserSerializer

  def attendance_presence
    # object.attendances.present?
    Project.includes(:attendances).find(object.id).attendances.present?
  end

  def able_start
    !object.tutor.projects.not_done.present?
  end

end