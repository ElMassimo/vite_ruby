FROM ruby:3.0 AS builder

# Install nodejs in the ruby image
RUN curl -sL https://deb.nodesource.com/setup_15.x | bash - && apt-get install -y nodejs
RUN npm install -g yarn

# Gems and packages will be cached in a separate image using a mounted volume.
ENV BUNDLE_PATH /bundler_cache
ENV YARN_CACHE_FOLDER /yarn_cache

# Set working directory inside the image home.
ENV APP_PATH /app
WORKDIR $APP_PATH
ADD . $APP_PATH
