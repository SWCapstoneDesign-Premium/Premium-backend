# About Premium Server

<div align="center">

  <img src="./appicon/icon1.png" style="width:30px;height:30px;">
  <!-- <img src="./appicon/icon2.png" style="width:200px"> -->

</div>

- [1. 개발 환경](#1.-개발-환경)
- [2. 기능 소개](#2.-기능-소개)
- [3. 3rd-party API](#3.-3rd-party-API)
- [4. Getting Started](#4.-Getting-Started)
- [5. 배포](#5.-배포)

## 1. 개발 환경

```bash
Rails version             6.0.3.4
Ruby version              ruby 2.6.5p114 [x86_64-darwin16]
RubyGems version          3.0.3
Rack version              2.2.3
Bundler                   2.2.6
Python version            3.9.4
Selenium version          3.141.0
Database adapter          postgres (PostgreSQL) 13.2
nginx version             nginx/1.14.0 (Ubuntu 18.04 LTS)
Phusion Passenger(R)      6.0.8
```

## 2. 기능 소개

우리는 공부를 비교적 잘하는 멘토들이 공부에 어려움을 겪거나 발전을 원하는 튜티들을 자신이 공부했던 패턴에 따라 학습시키며,  
튜티들이 해당 패턴에 적응하여, 성적향상을 이루고, 프로젝트 이후 자기주도학습으로 유도해주는 프로젝트를 구상하였습니다.
때문에 따라하는 스터디 프로젝트라고 하여 프로젝트명은 따숲입니다.

1. 튜터들은 프로젝트 생성 시, 튜티들을 공부시킬 책을 선정하고 여러 옵션에 따라 일정을 자동적으로 생성해줍니다.

   - 일정은 에빙하우스의 망각곡선을 분석하여 전날 공부했던 내용을 복습 강도를 설정하여 복습과 학습의 비율을 조정할 수 있다.
   - 일정은 책의 목차에 튜터들이 가중치를 입력하게 되면, 이에 따라 프로젝트 기간내에서 각 가중치 비율에 맞게 각 목차의 학습일정이 분산됩니다.
   - 일정은 튜터가 휴식 옵션을 부여할 수 있어서 유연하게 튜티들에게 휴식을 부여할 수 있습니다.
   - 튜터의 편의를 위해 책 검색 api를 제공하여 책을 검색할 수 있게 하였고, 이에 대한 목차를 크롤링하는 기능을 구현했습니다.

2. 튜터들이 프로젝트를 만들면, 튜티들은 체험기간 동안 프로젝트를 체험할 수 있게됩니다.

   - 튜터들의 프로필을 확인하고 프로젝트를 선택해도 튜티 자신과는 맞지 않을 수 있기에 체험기간을 부여합니다.

3. 체험기간이 끝나면 보증금을 내고 프로젝트에 정식으로 참여할 수 있습니다.

   - 보증금은 수업료가 아닌 공부에 동기를 부여하기 위한 방식으로 환급 정책에 따라 일정 비율 이상 일일공부인증을 하게 되면 전액 환급 받을 수 있습니다.

4. 프로젝트에 정식참여하게 되면, 튜티들은 각 일정에 맞는 공부를 한 뒤, 튜터가 지정한 방식으로 일일 인증을 수행해야합니다.

   - 일일 인증이란? 튜터의 편의성을 위하여 튜티들이 학습내용에 대해 사진을 찍어 업로드 할 수 있습니다.

5. 사용자들의 편의을 위해 소셜 로그인(애플, 카카오)기능을 구현하였고, 유저 정보의 보안을 지키기 위해 높을 보안성을 가지는 [jwt](https://jwt.io/) 방식을 차용하였습니다.

6. 서비스 관리자는 사용자들이 학교 인증을 하여 튜티자격을 요청하면, 이를 확인하고 튜터 자격을 부여할 수 있습니다.

## 3. 3rd party API

### 아래는 프로젝트에서 사용된 외부 API 목록입니다

- [I'mport;](https://www.iamport.kr/)
- [Daum kakao Book search](https://developers.kakao.com/docs/latest/ko/daum-search/dev-guide#search-book)
- [Kakao Developer Omniauth](https://developers.kakao.com/docs/latest/ko/kakaologin/rest-api)
- [Apple Developer Omniauth](https://developer.apple.com/kr/sign-in-with-apple/get-started/)

## 4. Getting Started

1. 프로젝트 설정
   - application.yml과 database.yml을 만들고 설정해야합니다.

```bash
# project download from git
$ git clone https://github.com/SWCapstoneDesign-Premium/Premium-backend.git

# download and set dependency
$ bundle install

# create application.yml
$ figaro install

# create database.yml
$ touch config/database.yml
```

2. application.yml 설정

```yml
# project secret key
SECRET_KEY_BASE:

# aws
AWS_ACCESS_ID:
AWS_ACCESS_SECRET_KEY:
AWS_REGION:
AWS_S3_END_POINT:

# db
DB_NAME:
DB_USER_NAME:
DB_USER_PASSWD:

# kakao omniauth
KAKAO_CLIENT_ID:
REDIRECT_PATH:

# i'mport api set
IAMPORT_API_KEY:
IAMPORT_API_SECRET_KEY:
IAMPORT_ID:

# apple api omniauth
APPLE_CLIENT_ID:
APPLE_TEAM_ID:
APPLE_KEY:
APPLE_PEM:
APPLE_REDIRECT_URI:
```

3. database.yml 설정

```yml
## config/database.yml
## Database은 Environment에 따라 분리 시켜서 해주는게 가장 좋습니다.

#
#   Ensure the SQLite 3 gem is defined in your Gemfile
#   gem 'sqlite3'
#
default: &default
  adapter: postgresql
  host: localhost
  encoding: utf8
  username: <%= ENV["DB_USER_NAME"] %>
  password: <%= ENV["DB_USER_PASSWD"] %>
  pool: 5

development:
  <<: *default
  database: <%= ENV["DB_NAME"] %>_<%= Rails.env %>

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<: *default
  database: <%= ENV["DB_NAME"] %>_<%= Rails.env %>

production:
  <<: *default
  database: <%= ENV["DB_NAME"] %>_<%= Rails.env %>
```

4. local에서 서버 돌리기

```bash
# db 설정하고 더미데이터 생성
$ rails db:create
$ rails db:migrate
$ rails db:seed

# 서버 실행
$ rails s
```

## 5. 배포

- [따숲](https://www.ddasup.ga)
- [따숲 관리자](https://www.ddasup.ga/admin)
