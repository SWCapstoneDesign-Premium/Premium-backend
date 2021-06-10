require 'rails_helper'

RSpec.describe "Books", type: :request do
  let(:new_book) { Book.create(
    author: "차덕원",
    content: "최신 전국 듣기 능력 평가 문제를 총정리하고 고난도 문제까지 완벽 대비할 수 있게 훈련시키는 듣기 총정리 모의고사  [교재 특징] 1. 출제 유형의 철저한 분석과 반복적 집중 훈련 - 최신 기출 문제를 철저히 분석하여 중3 전국 듣기 능력 평가에 출제되는 주요 유형들에 대한 효과적인 풀이 방법을 제시하였습니다. - 앞에서 학습한 풀이 방법을 적용시킬 수 있는 예상 문제를 유형별로 묶어 집중적으로 풀어보면서 실전 대비를 위한 훈련을 할 수 있습니다",
    isbn: "1162400587 9791162400586",
    publisher: "수경출판사",
    image: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F3759859%3Ftimestamp%3D20210503140209",
    url: "https://search.daum.net/search?w=bookpage&bookId=3759859&q=%EC%A4%91%EB%93%B1+%EB%93%A3%EA%B8%B0+%EC%B4%9D%EC%A0%95%EB%A6%AC+%EB%AA%A8%EC%9D%98%EA%B3%A0%EC%82%AC+25%ED%9A%8C+%EC%A4%913%28%EC%9E%90%EC%9D%B4%EC%8A%A4%ED%86%A0%EB%A6%AC%29%28%EC%9E%90%EC%9D%B4%EC%8A%A4%ED%86%A0%EB%A6%AC%29"
  )}
  let(:tutor) { FactoryGirl.create(:tutor)}

  let(:token) do
    tutor
    post user_session_path, params: {"user": { "email": tutor.email, "password": "password"}}
    token = ActiveSupport::JSON.decode(response.body)["token"]
  end

  before :all do
    @book = FactoryGirl.create(:book)
    @book.crawl_book_index
  end
  
  describe "책 생성" do
    context "정상적인 책 생성" do
      it "이미 존재하는 책 생성 요청" do
        post books_path, params: {book: {
          author: "홍성대",
          content: "- 독자대상 : 고등학교 1학년 및 고등학교 수학 학습자 - 구성 : 개념 정리 + 연습 문제 - 특징 : ① 수학의 기본을 알기 쉽게 정리 ② 새 교육과정에 맞추어 꾸며짐",
          isbn: "8988399005 9788988399002",
          publisher: "성지출판",
          image: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F1271676%3Ftimestamp%3D20190127134651",
          url: "https://search.daum.net/search?w=bookpage&bookId=1271676&q=%EC%88%98%ED%95%992+%EA%B3%A01%28%EA%B8%B0%EB%B3%B8%ED%8E%B8%29%282017%29%28%EC%88%98%ED%95%99%EC%9D%98+%EC%A0%95%EC%84%9D%29%28%EA%B0%9C%EC%A0%95%ED%8C%90+11%ED%8C%90%29%28%EC%96%91%EC%9E%A5%EB%B3%B8+HardCover%29"
        }}, headers: { "Authorization": token }
        expect(response).to have_http_status(200)
      end

      it "새로운 책 생성 요청" do
        post books_path, params: {book: {
          author: "차덕원",
          content: "최신 전국 듣기 능력 평가 문제를 총정리하고 고난도 문제까지 완벽 대비할 수 있게 훈련시키는 듣기 총정리 모의고사  [교재 특징] 1. 출제 유형의 철저한 분석과 반복적 집중 훈련 - 최신 기출 문제를 철저히 분석하여 중3 전국 듣기 능력 평가에 출제되는 주요 유형들에 대한 효과적인 풀이 방법을 제시하였습니다. - 앞에서 학습한 풀이 방법을 적용시킬 수 있는 예상 문제를 유형별로 묶어 집중적으로 풀어보면서 실전 대비를 위한 훈련을 할 수 있습니다",
          isbn: "1162400587 9791162400586",
          publisher: "수경출판사",
          image: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F3759859%3Ftimestamp%3D20210503140209",
          url: "https://search.daum.net/search?w=bookpage&bookId=3759859&q=%EC%A4%91%EB%93%B1+%EB%93%A3%EA%B8%B0+%EC%B4%9D%EC%A0%95%EB%A6%AC+%EB%AA%A8%EC%9D%98%EA%B3%A0%EC%82%AC+25%ED%9A%8C+%EC%A4%913%28%EC%9E%90%EC%9D%B4%EC%8A%A4%ED%86%A0%EB%A6%AC%29%28%EC%9E%90%EC%9D%B4%EC%8A%A4%ED%86%A0%EB%A6%AC%29"
        }}, headers: { "Authorization": token }
        expect(response).to have_http_status(200)
      end
    end
  end


  describe "목차 가져오기" do 
    context "책의 챕터가 없을 경우" do
      it "정상적인 크롤링 요청" do
        new_book
        get get_list_books_path, params:{ book: {isbn: new_book.isbn }}, headers: { "Authorization": token }
        expect(response).to have_http_status(200)
      end
    end

    context "책의 챕터가 존재할 경우" do
      it "정상적인 목차 요청" do
        get get_list_books_path, params:{ book: {isbn: @book.isbn }} , headers: { "Authorization": token }
        expect(response).to have_http_status(200)
      end      
    end

  end

end
