---
title: "Gatsby란 뭘까? (작성중)"
date: 2023-09-20 20:53:00 +09:00
categories: [Dev, Web]
# tags: [writing]
render_with_liquid: false
---

## Gatsby란?
Gatsby도 앞선 포스팅에서 설명한 Jekyll과 같이 정적 웹 사이트 및 애플리케이션 빌드를 위한 프레임워크 중 하나다.

다른 점은 Jekyll은 Ruby 언어를 사용하였지만, Gatsby는 React를 사용하였다.
React를 이용하였기에 컴포넌트의 재사용성을 활용할 수 있다는 장점이 있다.

### 특징
- React 기반
- 정적 사이트 생성
- 데이터 소스 플러그인 사용 가능
- GraphQL 쿼리 사용 가능
- 등등!


### 여담..
사실 나는 직접 만들어보며.. 부딪히며 깨닫는게 많다.

일단 해보자!!
[참고 링크](https://devfoxstar.github.io/web/github-pages-gatsby/)

### node, npm 재설치
gatsby 설치 시 node버전을 18이상 요구하여 아래 커맨드로 node, npm을 재설치함.
```bash
sudo rm -rf /usr/local/bin/npm /usr/local/share/man/man1/node* /usr/local/lib/dtrace/node.d ~/.npm ~/.node-gyp /opt/local/bin/node /opt/local/include/node /opt/local/lib/node_modules
sudo rm -rf /usr/local/lib/node* ; sudo rm -rf /usr/local/include/node* ; sudo rm -rf /usr/local/bin/node*
sudo apt-get purge nodejs npm

sudo apt install -y nodejs npm
sudo npm cache clean -f

sudo npm install npm
sudo npm install -g n
sudo n stable

node --version
npm --version
```

### Gatsby 설치
```bash
npm install -g gatsby-cli
```

### Gatsby 프로젝트 생성
하단 링크에서 원하는 테마를 선택한다.

https://www.gatsbyjs.com/starters/

원하는 테마를 골랐다면 아래 커맨드를 이용해 설치해준다.
```bash
gatsby new {프로젝트명} {테마 경로}
```
나의 경우에는 `gatsby-starter-datocms-homepage` 테마를 이용했다.
```bash
gatsby new gatsby-starter-datocms-homepage https://github.com/gatsbyjs/gatsby-starter-datocms-homepage
```
