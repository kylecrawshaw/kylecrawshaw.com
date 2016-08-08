#!/bin/bash
if ([ $TRAVIS_BRANCH == "master" ])
then
  echo 'Deploying to s3'
  lektor deploy s3
  echo 'Published new changes to s3. Changes should be live at kylecrawshaw.com'
else
  echo "Build successful, but not publishing!"
fi
