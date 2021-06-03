# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
AdminUser.destroy_all
p "어드민 삭제"
AdminUser.create!(email: 'admin@ddasoop.com', password: 'password', password_confirmation: 'password') 
p "어드민 유저 생성"

def generate_user
  %w(Tutor Tutee).each do |object|
    20.times do |i|
      object.constantize.create(
        email: "#{object}#{i+1}@test.com", 
        password: "password", 
        name: "#{Faker::Name::name.gsub(/\s+/, "")}", 
        phone: "010-"+ rand(1000..9999).to_s + "-" + rand(1000...9999).to_s,
        image: File.open("public/image/seedImage/seed#{rand(1..10)}.jpg"),
        status: (object == "Tutor") ? "approving" : "default")
      puts "#{object}#{i+1} 생성완료!"
    end
  end
end

def generate_project
  20.times.each do |i|
    project = Project.create(
      tutor_id: Tutor.first.id + i,
      description: "project code name project_#{i}",
      deposit: 15000,
      image: File.open("public/image/seedImage/seed#{rand(1..10)}.jpg"),
      title: "project #{i}",
      started_at: DateTime.now,
      duration: 60,
      experience_period: 14,
      category_id: Category.ids.shuffle.first
    )
    puts "#{project.id} 생성 완료"
  end
end

def generate_category
  %w(국어 수학 영어 과학탐구 사회탐구 기타).each do |title|
    Category.create(title: title)
  end
end

def generate_book
  Book.create(
    author: "홍성대",
    content: "- 독자대상 : 고등학교 1학년 및 고등학교 수학 학습자 - 구성 : 개념 정리 + 연습 문제 - 특징 : ① 수학의 기본을 알기 쉽게 정리 ② 새 교육과정에 맞추어 꾸며짐",
    isbn: "8988399005 9788988399002",
    publisher: "성지출판",
    image: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F1271676%3Ftimestamp%3D20190127134651",
    url: "https://search.daum.net/search?w=bookpage&bookId=1271676&q=%EC%88%98%ED%95%992+%EA%B3%A01%28%EA%B8%B0%EB%B3%B8%ED%8E%B8%29%282017%29%28%EC%88%98%ED%95%99%EC%9D%98+%EC%A0%95%EC%84%9D%29%28%EA%B0%9C%EC%A0%95%ED%8C%90+11%ED%8C%90%29%28%EC%96%91%EC%9E%A5%EB%B3%B8+HardCover%29"
  )
  puts "수학의 정석 생성"
  Book.create(
    author: "허민",
    content: "보카바이블 4.0은 13년간 영어어휘 베스트셀러인 보카바이블의 4번째 전면개정판입니다. 공무원, 편입, 토플, 텝스 등의 국내 영어 시험과 SAT, GRE 등 유학시험을 위한 영어어휘교재로서 국내 모든 영어시험의 30여 년간의 기출어휘를 집중분석하고 이를 빈출도순으로 배열하여 출제가능성을 고려한 수험효율성을 극대화하였고, 어원/숙어/동의어 학습 등 단계적 학습방법으로 암기 효율성을 극대화하였습니다. 이번 개정판은 A권과 B권 두 권으로 나누어 구성하였는데",
    isbn: "8994553096 9788994553092",
    publisher: "스텝업",
    image: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F1427372%3Ftimestamp%3D20210503135651",
    url: "https://search.daum.net/search?w=bookpage&bookId=1427372&q=%EB%B3%B4%EC%B9%B4%EB%B0%94%EC%9D%B4%EB%B8%94+4.0+%EC%84%B8%ED%8A%B8%28%EC%A0%842%EA%B6%8C%29"
  )
  puts "보카바이블 생성"
  Book.create(
    author: "차덕원",
    content: "최신 전국 듣기 능력 평가 문제를 총정리하고 고난도 문제까지 완벽 대비할 수 있게 훈련시키는 듣기 총정리 모의고사  [교재 특징] 1. 출제 유형의 철저한 분석과 반복적 집중 훈련 - 최신 기출 문제를 철저히 분석하여 중3 전국 듣기 능력 평가에 출제되는 주요 유형들에 대한 효과적인 풀이 방법을 제시하였습니다. - 앞에서 학습한 풀이 방법을 적용시킬 수 있는 예상 문제를 유형별로 묶어 집중적으로 풀어보면서 실전 대비를 위한 훈련을 할 수 있습니다",
    isbn: "1162400587 9791162400586",
    publisher: "수경출판사",
    image: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F3759859%3Ftimestamp%3D20210503140209",
    url: "https://search.daum.net/search?w=bookpage&bookId=3759859&q=%EC%A4%91%EB%93%B1+%EB%93%A3%EA%B8%B0+%EC%B4%9D%EC%A0%95%EB%A6%AC+%EB%AA%A8%EC%9D%98%EA%B3%A0%EC%82%AC+25%ED%9A%8C+%EC%A4%913%28%EC%9E%90%EC%9D%B4%EC%8A%A4%ED%86%A0%EB%A6%AC%29%28%EC%9E%90%EC%9D%B4%EC%8A%A4%ED%86%A0%EB%A6%AC%29"
  )
  puts "자이스토리"
end

def generate_attendance
  Tutee.all.each do |tutee|
    attendance = tutee.attendances.create(project_id: Project.all.sample.id)
    attendance.auths.create
  end
end

def generate_seed
  puts "생성시킬 모델을 입력해주세요(끝내려면 done를 입력해주세요)"
  keyword = '', models = Array.new
  while true
    begin
      input = STDIN.gets.chomp
      break if input == 'done'
      input.classify.constantize
    rescue Exception
      puts "존재하지 않는 모델입니다."
    else
      models << input.classify
    end
  end
  User.destroy_all
  puts "유저 삭제 완료"
  generate_user
  models.each do |model|
    model.constantize.send("destroy_all")
    send("generate_#{model.downcase}")
    puts "#{model} seed 생성 완료"
  end
end


generate_seed