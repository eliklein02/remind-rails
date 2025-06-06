# Make sure it matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.5
FROM ruby:$RUBY_VERSION

RUN TERM=dumb

# Install libvips for Active Storage preview support
RUN echo 'DPkg::Options {"--force-confnew"; "--force-confdef";};' > /etc/apt/apt.conf.d/local && \
    DEBIAN_FRONTEND=noninteractive apt-get update -qq && \
    apt-get install -y --allow-downgrades build-essential libvips bash bash-completion libffi-dev tzdata postgresql nodejs npm ca-certificates apt-utils && \
    npm config set strict-ssl false && \
    npm install -g yarn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_LOG_TO_STDOUT="1" \
    RAILS_SERVE_STATIC_FILES="true" \
    RAILS_ENV="production" \
    BUNDLE_WITHOUT="development" 




# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

ARG SECRET_KEY_BASE
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}

# Copy application code
COPY . .

RUN yarn config set strict-ssl false

# Install JavaScript dependencies
RUN yarn install

ENV SECRET_KEY_BASE=1

RUN RAILS_ENV=production bundle exec rake assets:precompile

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile --gemfile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

RUN chmod +x /rails/bin/docker-entrypoint

# Entrypoint prepares the database.

# Start the server by default, this can be overwritten at runtime
EXPOSE 3070

# CMD ["wait-for-it.sh", "db:5432", "--", "./bin/rails", "server", "-p", "3500"]
CMD ["./bin/rails", "server", "-p", "3070"]