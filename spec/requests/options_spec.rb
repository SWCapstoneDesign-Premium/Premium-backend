require 'rails_helper'

RSpec.describe "Options", type: :request do
  
  before :all do
    @book = FactoryGirl.create(:book)
    @book.crawl_book_index
    @option_param = {
      "option": {
        "options": [
          {"weight": 1, id: @book.chapters.first.id}, 
          {"weight": 1, id: @book.chapters.second.id}
        ]
      }
    }
    @project = FactoryGirl.create(:project)
    @tutor = FactoryGirl.create(:tutor)
    @project.update!(book_id: @book.id, tutor_id: @tutor.id)
  end

  let(:token) do
    @tutor
    post user_session_path, params: {"user": { "email": @tutor.email, "password": "password"}}
    token = ActiveSupport::JSON.decode(response.body)["token"]
  end
      
  describe "옵션 조회 요청" do

    context "옵션 요청" do

      it "정상적인 요청일 경우" do
        get options_path, params:{ project_id: Project.first.id}, headers: {"Authorization": token}
        expect(response).to have_http_status(200)
      end

    end
  end
  
  describe "옵션 생성" do

    context "정상적인 옵션 생성" do
      it "정상적인 생성 요청" do
        post options_path, params: @option_param, headers: {"Authorization": token}
        expect(response).to have_http_status(200)
      end
    end

    context "비정상적인 옵션 생성 요청" do
      it "비정상적 요청" do
        @option_param[:option][:options].push({weight: 1, id: 1000})
        post options_path, params: @option_param, headers: {"Authorization": token}
        expect(response).to have_http_status(400)
      end
    end

  end
end
