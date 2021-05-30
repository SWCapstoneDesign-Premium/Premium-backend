class UsersController < ApiController
  before_action :authorize_check_request, except: %i(create update apple)
  before_action :load_user, except: %i(index apple create)

  def index
    @users = User.all
    @current_api_user
    render json: each_serializer(@users, UserSerializer), status: :ok
  end

  def show
    result = (@user) ? [@user, :ok] : [@user.errors.full_messages, :unprocessable_entity]
    render json: serializer(@user, UserSerializer, [:id, :name, :type]), status: :ok
  end
  
  def update
    begin
      @user.update user_params
      render json: serializer(@user, UserSerializer, [:id, :name, :email, :type]), status: :ok
    rescue => exception
      render json: {error: @user&.errors&.full_messages&.first}, status: :bad_request
    end
  end

  def destroy
    result = (@user.destroy) ? [@user, :ok] : [@user.destroy.errors.full_messages, ""]
    send_response(result)
  end


  def get_current_user
    begin
      render json: serializer(@current_user, UserSerializer, attributes: [:id, :name, :type]), status: :ok
    rescue => exception
      render json: {errors: @current_user&.errors&.full_messages&.first}, status: :bad_request
    end
  end

  def get_project_list
    begin
      if @current_user.is_a? Tutor
        projects = @current_user.projects
        render json: each_serializer(projects, ProjectSerializer), status: :ok
      else
        render json: { errors: "튜터만 접근 가능합니다"}, status: :bad_request
      end
    rescue => exception
      render json: { errors: "잘못된 접근입니다"}, status: :bad_request
    end
  end

  def apple
    auth_login("apple", true)
    # 모듈 써서 구현된 것은 정보만 받아서 생성 후 적용
  end
  
  # def mylikes
  #   begin
  #     likable_ids = @current_user.likes.pluck(:likable_id)
  #     users = User.where(id: likable_ids).includes(:likes)
  #     render json: each_serializer(users, UserSerializer, context: {likable_ids: likable_ids }), status: :ok
  #   rescue => exception
  #     render json: { errors: "좋아요누른 튜터를 찾을 수 없습니다."}, status: :bad_request
  #   end
  # end

  private
    
  def user_params
    params.require(:user).permit(User::PERMIT_COLUMNS)
  end 

  def load_user
    @user = User.find_by(id: params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: {errors: 'User not found'}, status: :not_found
  end
end
