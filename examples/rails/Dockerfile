FROM ruby:4.0.6 AS builder

# Install nodejs in the ruby image
RUN curl -sL https://deb.nodesource.com/setup_24.x | bash - && apt-get install -y nodejs
RUN npm install -g pnpm@12 && pnpm config set store-dir /pnpm_cache

# Gems and packages will be cached in a separate image using a mounted volume.
ENV BUNDLE_PATH /bundler_cache
ENV BUNDLER_VERSION 4.0.20

# Match the version of Bundler with that specified in Gemfile.lock
RUN gem update --system \
    && gem install bundler -v $BUNDLER_VERSION

# Set working directory inside the image home.
ENV APP_PATH /app
WORKDIR $APP_PATH
ADD . $APP_PATH
