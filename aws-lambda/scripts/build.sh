rm aws-lambda/function.zip || echo "ALL GOOD"
find build/ -delete || "ALL GOOD"
mkdir -p build
rsync -rv ./app/ ./build/ --filter=': /.rsync-filter'
# docker run -v "$PWD/build:/app" -v "$PWD/setup.sh:/app/setup.sh" -w /app -t python:3.13 bash ./setup.sh
pushd build
zip -r function.zip *
popd
mv build/function.zip aws-lambda/
