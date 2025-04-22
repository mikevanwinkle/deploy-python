#!/bin/bash
###########
# Package an amazon lambda layer
###########
find layer/ -delete
find aws-lambda/layer.zip -delete
mkdir -p layer
cd app; uv pip freeze > requirements.txt; cd ..
cp app/requirements.txt layer/
docker run -v "$PWD:/app" -w /app -t python:3.13 pip install -r app/requirements.txt --python-version 3.13 --platform manylinux2014_x86_64 --target layer/python --only-binary=:all:
pushd layer
zip -r layer.zip *
popd
mv layer/layer.zip aws-lambda/layer.zip
