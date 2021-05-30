class OptionsController < ApiController
  before_action :authorize_check_request
  before_action :check_auth, only: %i(create)

  def index
    begin
      tutor = Project.find_by(id: params[:project_id])&.tutor 
      option = tutor.present? ? tutor.options.includes(:chapter).ransack(start_at_lteq: DateTime.now, end_at_gteq: DateTime.now, m: "and").result.first : nil
      title = option.present? ? option&.chapter&.title : ""
      render json: { options: tutor&.options, chapter: title }
    rescue => exception
      render json: {error: "일정이 생성되지 않은 상태입니다."}, status: :not_found
    end
  end

  def create
    # 챕터부터 옵션까지 역탐색
    begin
      book = Chapter.find_by(id: option_params.dig(:options).first.dig(:id)).book
      begin
        tutor = book.projects.find_by(tutor: @current_user).tutor
        begin
          options = []
          # 튜터는 동시에 두 개이상의 프로젝트를 진행할 수 없음, 튜터가 기존에 만들어놨던 가중치와 관련된 것들은 비워줘야 함
          @current_user.options.destroy_all if @current_user.options.present? # bulk delete 적용
          option_params.dig(:options).each{ |option| (options ||= []) << tutor.options.build(weight: option[:weight], chapter_id: option[:id]) }
          Option.import options
          render json: { status: :ok }
        rescue => exception
          render json: {error: "옵션이 제대로 생성되지 않았습니다."}, status: :bad_request
        end
      rescue => exception
        render json: {error: "진행중인 프로젝트가 없습니다."}, status: :not_found
      end
    rescue => exception
      render json: {error: "해당 챕터를 가진 책이 존재하지 않습니다."}, status: :not_found
    end
  end

  def option_params
    params.fetch(:option, {}).permit(Option::PERMIT_COLUMNS)
  end
end