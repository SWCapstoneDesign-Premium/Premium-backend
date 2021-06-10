require 'rails_helper'

RSpec.describe "Attendances", type: :request do

  let(:project) { FactoryGirl.create(:project)}
  let(:tutee) { FactoryGirl.create(:tutee) }
  let(:tutor) { FactoryGirl.create(:tutor) }
  let(:attendance) { Attendance.create(project: project, tutee: tutee)}
  let(:tutee_token) do
    tutee
    post user_session_path, params: {"user": { "email": tutee.email, "password": "password"}}
    token = ActiveSupport::JSON.decode(response.body)["token"]
  end

  let(:tutor_token) do
    tutee
    post user_session_path, params: {"user": { "email": tutee.email, "password": "password"}}
    token = ActiveSupport::JSON.decode(response.body)["token"]
  end

  describe "Attendance 조회" do
    context "정상적인 조회 요청" do
      it "조회 성공" do
        get attendances_path, headers: { "Authorization": tutee_token }
        expect(response).to have_http_status(200)
      end
    end

    context "비정상적인 조회 요청" do
      it "현재 유저가 없는 경우" do
        get attendances_path
        expect(response).to have_http_status(401)
      end
    end
  end

  describe "Attendance 생성" do
    context "정상적인 생성 요청" do
      it "성공" do
        post attendances_path, params: {project_id: project.id}, headers: { "Authorization": tutee_token }
        expect(response).to have_http_status(200)
      end
    end

    context "비정상적인 생성 요청" do

      it "없는 프로젝트 id 요청" do
        attendance
        post attendances_path, params: {project_id: Project.last.id + 10}, headers: { "Authorization": tutee_token }
        expect(response).to have_http_status(404)
      end
      
      it "현재 유저가 튜티가 아닌 경우" do
        attendance
        post attendances_path, params: {project_id: Project.last}, headers: { "Authorization": tutor_token }
        expect(response).to have_http_status(404)
      end

    end
  end
end
