class ApiController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?
  # before_action :authorize_access_request!, if: :authorize_controller?
  include JWTSessions::RailsAuthorization
  rescue_from JWTSessions::Errors::Unauthorized, with: :not_authorized

  def not_found
    render json: { error: 'not_found' } 
  end
  
  def check_auth
    # 튜터가 인증이 되었는지 & auth 모델이 있는지 체크
    ## false일 경우는 인증이 되어 있지 않은 경우 
    (@current_user.is_a? Tutor) ? (@current_user.auths.present? && @current_user.approved?) : false
  end

	def check_user_type
	  return render json: {error: "접근 권한이 없습니다." }, status: :unauthorized unless @current_user.is_a? Tutor
	end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: User::PERMIT_COLUMNS)
    devise_parameter_sanitizer.permit(:account_update, keys: User::PERMIT_COLUMNS)
  end
  
  protected
  
  def authorize_check_request
    raise JWTSessions::Errors::Unauthorized unless request.headers.include? "Authorization"
    begin
      authorize_access_request!
      @current_user ||= User.find(payload["user_id"])
    rescue JWTSessions::Errors, ActiveRecord::RecordNotFound, JWT::DecodeError => exception
      puts exception.class
      Rails.logger.info exception
      @current_user = nil
      raise JWTSessions::Errors::Unauthorized
    rescue => exception
      puts exception.class
      Rails.logger.info exception
      @current_user = nil
    end
  end

  private
 
	def serializer object, serializer, context = nil, attributes = []
		serializer.new(only: attributes, context: context).serialize(object)
	end

	def each_serializer objects, serializer, context: nil
		Panko::ArraySerializer.new(
			objects,
      context: context,
			each_serializer: serializer
		).to_a
	end

  def auth_login(provider, only_params)
    auth_hash = only_params ? params : request.env["omniauth.auth"]
    sns_login = SnsLogin.new(auth_hash, @current_user, only_params) 
    @user = sns_login.find_user_oauth
    begin
      if @user.persisted?
        if @user.sign_in_count == 0 # sns로 첫 가입 시 별도 처리하기 위해서 추가했습니다.
          # 회원 가입 진행
          payload = { user_id: @user.id }
          session = JWTSessions::Session.new(payload: payload, refresh_by_access_allowed: true)
          tokens = session.login
          
          response.set_cookie(
            JWTSessions.access_cookie,
            value: tokens[:access],
            httponly: true,
            secure: Rails.env.production?,
          )
  
          render json: { csrf: tokens[:csrf], token: tokens[:access], refresh_token: tokens[:refresh] ,is_omniauth: true , user_id: @user.id} and return
        else
          # 로그인 진행
          payload = { user_id: @user.id}
          session = JWTSessions::Session.new(payload: payload, refresh_by_access_allowed: true)
          tokens = session.login
          render json: { csrf: tokens[:csrf], token: tokens[:access], refresh_token: tokens[:refresh] ,is_omniauth: true } and return
        end
      else
        session["devise.#{provider}_data"] = auth_hash
        # redirect_to new_user_registration_url, notice: '로그인 에러가 발생하였습니다.'
        render json: {errors: "로그인 에러가 발생했습니다"}, status: :not_found
      end
    rescue 
      session["devise.#{provider}_data"] = auth_hash
      render json: {errors: "로그인 에러가 발생했습니다"}, status: :not_found
    end
  
  end

  def not_authorized
    render json: { error: "Not authorized" }, status: :unauthorized
  end
end
