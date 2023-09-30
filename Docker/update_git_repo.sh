#!/bin/bash

git clone https://github.com/SagiK-Repository/Docker_Tensorflow_Repository.git /app/git_repository

# # Git 저장소 클론 또는 업데이트
# if [ -d "/app/git_repository" ]; then
#   # 이미 저장소가 존재하는 경우, Pull 수행
#   cd /app/git_repository
#   git pull origin main
# else
#   # 저장소가 없는 경우, 클론 수행
#   git clone https://github.com/SagiK-Repository/Docker_Tensorflow_Repository.git /app/git_repository
# fi