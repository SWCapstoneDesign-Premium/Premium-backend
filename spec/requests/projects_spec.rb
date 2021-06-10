require 'rails_helper'

RSpec.describe "Projects", type: :request do
  

  let(:tutor) { FactoryGirl.create(:tutor) }
  
  let(:token) do
    tutor
    post user_session_path, params: {"user": { "email": tutor.email, "password": "password"}}
    token = ActiveSupport::JSON.decode(response.body)["token"]
  end
  
  

  5.times do |i|
    let("project#{i}") { FactoryGirl.create(:project) }
  end 

  describe "프로젝트 조회" do
    describe "프로젝트 전체 조회" do
      it "전체 조회 성공" do
        get projects_path, headers: { "Authorization": token}
        expect(response).to have_http_status(200)
      end
    end

    describe "튜터의 프로젝트 조회" do 
      it "정상적인 조회" do 
        get projects_path, params: { q: {tutor_id_eq: tutor.id }}, headers: { "Authorization": token }
        expect(response).to have_http_status(200)
      end

      it "없는 튜터 id" do
        get projects_path, params: { q: {tutor_id_eq: 50 }}, headers: { "Authorization": token }
        expect(response).to have_http_status(400)
      end
      # it "해당 튜터가 만든 프로젝트가 없을 경우" do
      #   get projects_path, params: { q: {tutor_id_eq: tutor.id }}, headers: { "Authorization": token }
      #   expect(response).to have_http_status(200)
      # end
    end

    describe "특정 프로젝트 검색" do
      it "정상적인 프로젝트 검색 요청" do
        get projects_path, params: { q: { title_or_description_i_cont: project1.title[0..2] }}, headers: { "Authorization": token }
        expect(response).to have_http_status(200)
      end
    end
  end
 
  describe "프로젝트 생성" do
		context "정상" do
			it "정상 일 때" do
				post projects_path, params: { "project": {tutor_id: tutor.id, experience_period: 14, description: "설명", deposit: rand(10000..99999), title: "프로젝트 #{rand(1..9)}" } }, headers: {"Authorization": token}
				expect(response).to have_http_status(200)
			end
		end
		
		context "비정상" do
			it "제목 누락" do
        post projects_path, params: { "project": {tutor_id: tutor.id, experience_period: 14, description: "설명", deposit: rand(10000..99999)} }, headers: {"Authorization": token}
				expect(response).to have_http_status(400)
			end
		end

	end

  describe "프로젝트 일정 생성" do
    before :all do
      @book = FactoryGirl.create(:book)
      @book.crawl_book_index
      @arr = []
      @book.chapters.each do |chapter|
        @arr.push({"weight": 1, "id": chapter.id})
      end
      @option_param = {
        "option": {
          "options": @arr
        }
      }
      @project = FactoryGirl.create(:project)
      @tutor = FactoryGirl.create(:tutor)
      @project.update!(book_id: @book.id, tutor_id: @tutor.id)
      post user_session_path, params: {"user": { "email": @tutor.email, "password": "password"}}
      @token = ActiveSupport::JSON.decode(response.body)["token"]
      post options_path, params: @option_param, headers: {"Authorization": @token}

    end
    
    context "정상적인 일정 생성" do
      it "휴식 포함 일정 생성" do
        @project.update(tutor: @tutor)
        get project_create_schedule_path(@tutor.projects.first.id), params: { project_id: @tutor.projects.first.id, rest: 1 }, headers: {"Authorization": @token}
        expect(response).to have_http_status(200)
      end

      it "휴식 제외 일정 생성" do
        @project.update(tutor: @tutor)
        get project_create_schedule_path(@tutor.projects.first.id), params: { project_id: @tutor.projects.first.id, rest: 0 }, headers: {"Authorization": @token}
        expect(response).to have_http_status(200)
      end
    end
  end
end
