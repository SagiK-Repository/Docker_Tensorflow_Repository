문서정보 : 2023.09.27.~ 작성, 작성자 [@SAgiKPJH](https://github.com/SAgiKPJH)

<br>

# Docker_Tensorflow_Repository

  

- 아래 조건을 만족해야 합니다.
  1. Tensorflow gpu를 활용하여 docker로 실행합니다.
  2. 이미지를 만듭니다. git이 기본적으로 설치되어 있습니다.
  3. 그 이미지를 실행할 때 마다 특정 git 주소에서 그 컨테이너 내부 저장소에 최신 버전을 다운받습니다.
  4. 이미지를 실행할 때마다, 최신 버전의 git 주소 파일을 다운받기 때문에, 언제 어디서든 최신 환경에서 작업할 수 있습니다.
  5. 그 컨테이너 내부 repository 저장소에 vscode로 접근 가능합니다.
  6. 최종적으로 작업이 완료되면 다시 git 업로드 할 수 있습니다.
- 이는 저장공간을 Git에 두지만, 별도 공간은 계속 바뀔 수 있는 구조입니다.

### 제작자
[@SAgiKPJH](https://github.com/SAgiKPJH)

<br><br>

---

<br><br>

# Docker File 제작 및 실행

- dockerfile 내용
  ```dockerfile
  # 기반이 될 이미지 선택
  FROM tensorflow/tensorflow:latest-gpu
  
  # 필요한 패키지 설치, cache 비우기
  RUN apt-get update && \
      apt-get install -y curl sudo && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
  
  ### Git
  # Git 설치
  RUN apt-get update && apt-get install -y git
  
  # 작업 디렉토리 설정
  WORKDIR /app
  
  # Git 저장소 업데이트 스크립트 추가
  COPY update_git_repo.sh /app/update_git_repo.sh
  
  # 스크립트 실행 권한 부여
  RUN chmod +x /app/update_git_repo.sh
  
  # 컨테이너 실행 시 스크립트 자동 실행 설정
  CMD ["/app/update_git_repo.sh"]
  
  ENV WORKDIR="/app/git_repository"
  ###
  
  ### VSCode
  # 새로운 사용자 생성 및 비밀번호 설정
  ENV USER="user" \
      PASSWORD="password"
  RUN useradd -m ${USER} && echo "${USER}:${PASSWORD}" | chpasswd && adduser ${USER} sudo && \
      sed -i "/^root/ c\root:!:18291:0:99999:7:::" /etc/shadow
  
  # code-server 설치 및 세팅
  ENV WORKINGDIR="/home/${USER}/vscode"
  RUN curl -fsSL https://code-server.dev/install.sh | sh && \
      mkdir ${WORKINGDIR} && \
      su ${USER} -c "code-server --install-extension ms-python.python \
                                 --install-extension ms-azuretools.vscode-docker" && \
      rm -rf ${WORKINGDIR}/.local ${WORKINGDIR}/.cache
  
  # code-server 시작
  USER ${USER}
  ENTRYPOINT nohup code-server --bind-addr 0.0.0.0:8080 --auth password  ${WORKDIR}
  ###
  ```
- docker vscode 추가 내용은 (https://github.com/SagiK-Repository/Docker_VSCode/blob/main/README.md)를 참고했습니다.
- `update_git_repo.sh` 구성
  ```bash
  # Git 저장소 클론 또는 업데이트
  if [ -d "/app/git_repository" ]; then
    # 이미 저장소가 존재하는 경우, Pull 수행
    cd /app/git_repository
    git pull origin master
  else
    # 저장소가 없는 경우, 클론 수행
    git clone https://github.com/SagiK-Repository/Docker_Tensorflow_Repository.git /app/git_repository
  fi
  ```
- 다음과 같이 docker를 준비합니다.
  ```bash
  docker build -t tensorflow_gpu_vscode_gitrepo_iamge .
  docker run --gpus all --name tensorflow_gpu_vscode_gitrepo -p 18081:8080 tensorflow_gpu_vscode_gitrepo_iamge:latest 
  ```
