class ProjectsController < ApiController
  before_action :authorize_check_request
	before_action :check_user_type, except: %i(index show)
  before_action :load_project, except: %i(index show create create_schedule refund)
	
	def index
		begin
      projects = (params[:q]&.include?(:tutor_id_eq) && @current_user.is_a?(Tutor)) ? @current_user.projects : Project.all
      if (!@current_user.id.eql?(params.dig(:q,:tutor_id_eq).to_i) && params.dig(:q, :tutor_id_eq).present?)
        render json: { error: "잘못된 프로젝트 조회 접근입니다" }, status: :bad_request 
      else
        projects = projects.joins(:tutor).ransack(params[:q]&.except(:tutor_id_eq)).result.order("likes_count desc")
        render json: each_serializer(projects, ProjectSerializer), status: :ok
      end
		rescue => exception
			render json: { error: "프로젝트 조회 실패" }, status: :bad_request
		end
	end

	def create
		begin
      # 프로젝트는 동시에 하나만 진행 가능함
			project = @current_user.projects.create(project_params) unless @current_user.projects.not_done.present?
			render json: serializer(project, ProjectSerializer) 
		rescue => exception
			render json: {error: project&.errors&.full_messages&.first}, status: :bad_request
		end
	end

	
	def show
		# show는 자신의 프로젝트가 아니더라도 접근 가능해야하므로 load_project로 참조해오는 것은 적합하지 않음, 체험기간에도 볼 수 있어야하므로
		begin
			project = Project.find(params[:id])
			render json: serializer(project, ProjectSerializer)
		rescue => exception
			render json: {error: project.errors&.full_messages&.first}, status: :bad_request
		end
	end

	def update
		begin
			@project.update(project_params)
			render json: serializer(@project, ProjectSerializer)
		rescue => exception
			render json: {error: @project&.errors&.full_messages&.first}, status: :bad_request			
		end
	end

	def destroy
		begin
			@project.destroy
			render json: { status: :ok }
		rescue => exception
			render json: {error: project&.errors&.full_messages&.first}, status: :bad_request			
		end
	end

	def create_schedule
		begin
      project = @current_user.projects.find(params[:project_id]) if @current_user.projects.present?
      project.update(rest: params[:rest].to_i)
			project.allow_rest? ? project.make_schedule_with_rest : project.make_schedule_without_rest
			render json: {
				options: project.tutor.options,
				project: serializer(project, ProjectSerializer)
			}, status: :ok
		rescue => exception
			render json: {error: project&.errors&.full_messages&.first}, status: :bad_request
		end
	end

  def refund
    begin
      # 일단은 동기처리
      project = @current_user.projects&.find_by(id: params.dig(:project_id))
			project.refund_all_tutties
			render json: { status: :ok }
		rescue => exception
			render json: {error: project&.errors&.full_messages&.first}, status: :bad_request			
		end
  end

	protected

	def load_project
		@project = @current_user.projects.find(params[:id]) if @current_user.projects.present?
	end

	def project_params
		params.require(:project).permit(Project::PERMIT_COLUMNS)
	end

end

