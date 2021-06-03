class Project < ApplicationRecord
  
  include ImageUrl
  include Imageable
  include Iamport

  PERMIT_COLUMNS = %i(description deposit image title started_at duration experience_period category_id required_time review_weight mission book_id rest chat)
  
  has_many :attendances, dependent: :nullify
	has_many :auths, through: :attendances, as: :authable
  belongs_to :tutor, optional: true
  belongs_to :category, optional: true
  belongs_to :book, optional: true

  enum rest: %i(disallow_rest allow_rest)

  ransacker :rest, formatter: proc {|v| rests[v]}

  enum chat: %i(disable able)

  enum status: %i(ready running done)
  ransacker :status, formatter: proc {|v| statues[v]}

  def set_data_before_make_schedule
    @start_at, @end_at = DateTime.now, DateTime.now
    msg = ''
    begin
      @tutor = self.tutor
    rescue => exception
      msg = "프로젝트에 튜터가 등록되지 않았습니다."
      puts msg
    end
    
    begin
      @book = self.book
    rescue => exception
      msg = "프로젝트에 책이 등록되지 않았습니다."
      puts msg
    end
    
    begin
      @chapters = @book.chapters.order('id asc').joins(:options)
    rescue => exception
      msg = "책에 목차가 존재하지 않습니다."
      puts msg
    end

    begin
      @chapters.each{ |chapter| (@options ||= []) << chapter.options.find_by(tutor: self.tutor) if chapter.options.find_by(tutor: self.tutor) }
      @weight_sum ||= @options.pluck(:weight).inject(0, &:+)
    rescue => exception
      msg = "챕터에 대한 옵션이 없습니다."
      puts msg
    else
      puts "데이터 설정 완료"
    end

    # 실제 비율로 계산된 시간들 계산
    @options.each do | option |
      real_ratio_alloc_day = self.duration * ( option.weight.to_f / @weight_sum )
      (@real_ratio_alloc_days ||= []) << { id: option.id, day: real_ratio_alloc_day }
    end
    
    # 실제 비율로 나눠진 기간과 버림으로 인해 잘라진 기간의 차이 => n개
    diff ||= self.duration - (@real_ratio_alloc_days.pluck(:day).map(&:to_i).compact.sum)

    # 상위 n개 추출
    @recongnize_days = @real_ratio_alloc_days.sort_by{ |r| r[:day] }.last(diff)

  end

  # DateTime.on_weekend? => 주말인지 아닌지 true : false

  # 휴식 없는 스케쥴 생성
  # 기간 * w_i / sigma(w_i)
  # 소수점 이하 자리가 같은 경우, 상위 n(남은 기간(버림으로 발생하는))개 랜덤으로 분배
  # O(nlogn)
  def make_schedule_without_rest
    
    set_data_before_make_schedule

    @options.each_with_index do | option, index |
      @start_at = index != 0 ? @end_at + 1.days : self.started_at # 첫 인덱스면, 첫 챕터니까 이 챕터의 시작일은 프로젝트의 시작일과 같다. 정렬 순서 뒤바꾸지 않는 이상 괜찮다 created_at
      real_ratio_alloc_day = self.duration * ( option.weight.to_f / @weight_sum )
      @end_at =  @start_at + (@recongnize_days.pluck(:id).include?(option.id) ? real_ratio_alloc_day.to_i.days : (real_ratio_alloc_day.to_i - 1).days)
      option.update(start_at: @start_at.at_beginning_of_day, end_at: @end_at.at_end_of_day)
    end

    # Option.import @options.to_ary, on_duplicate_key_update: %i(start_at end_at)

  end

  # 휴식있는 스케쥴 생성
  # ( 기간 + 챕터 수) * w_i / sigma(w_i) -> 각 결과는 휴일 1일 포함된 날이 나옴 => 휴일 1일 제외해야됨
  # 챕터 수가 max를 넘어가면, max로 설정 뒤 챕터 사이에 휴일 랜덤으로 분배
  # max는 기간의 20%
  # 챕터 당 휴일 1일이 default이다. max를 넘을 경우는 max가 휴일의 수와 동일
  def make_schedule_with_rest
    
    set_data_before_make_schedule
   
    @holiday_upper_bound ||= (self.duration * 0.2).to_i
    
    # 휴일 랜덤으로 뽑는 로직
    grant_holiday_options = @options.pluck(:id).shuffle.last((@holiday_upper_bound < @options.count ? @holiday_upper_bound : @options.count))
  
    @options.each_with_index do | option, index |
      @start_at = index != 0 ? @end_at + 1.days : self.started_at # 첫 인덱스면, 첫 챕터니까 이 챕터의 시작일은 프로젝트의 시작일과 같다. 정렬 순서 뒤바꾸지 않는 이상 괜찮다 created_at
      real_ratio_alloc_day = self.duration * ( option.weight.to_f / @weight_sum )
      @end_at =  @start_at + (@recongnize_days.pluck(:id).include?(option.id) ? real_ratio_alloc_day.to_i.days : (real_ratio_alloc_day.to_i - 1).days)
      if grant_holiday_options.include?(option.id)
        @end_at += 1.day
        option.update(start_at: @start_at.at_beginning_of_day, end_at: @end_at.at_end_of_day, holiday: 'holiday')
      else
        option.update(start_at: @start_at.at_beginning_of_day, end_at: @end_at.at_end_of_day)
      end
    end

    # Option.import @options.to_ary, on_duplicate_key_update: { columns: %i(start_at end_at holiday) }
  
  end

  def refund_all_tutties
    if self.attendances.yet.present?
      self.attendances.yet.each do | attendance |
        # 인증 중 확인받은 것의 갯수 세기
        authentication_rate = attendance.auths.confirm.count.to_f / self.duration
        percentage = authentication_rate * 100

        @amount = case percentage
          when 0..49 then 0
          when 50..79 then self.deposit * 0.5
          when 80..100 then self.deposit
          else -1
        end

        # 카카오페이는 부분환불을 지원하지 않음
        if @amount > 0
          code, message, response = Iamport.iamport_cancel(attendance.imp_uid, @amount)
          case code 
            # 제대로 환급
            when true
              Rails.logger.info message
              attendance.complete!
            # 이미 환급된 경우
            when false
              Rails.logger.info message
              attendance.complete!
            # 나머지
            else
              Rails.logger.info "환급과정에서 오류가 발생하였습니다.(부분환불 미지원 PG 등)"
          end
        else
          Rails.logger.info "환급이 필요없거나 잘못 계산되었습니다."
        end

      end
    
    else
      Rails.logger.info "참여자가 없습니다."
    end

  end

end
