FROM ruby:2

RUN apt-get update && \
    apt-get install -y net-tools

COPY /app/Gemfile /app/Gemfile
RUN cd /app; bundle install
COPY /app/app.rb /app/app.rb

EXPOSE 8080
CMD ["ruby", "/app/app.rb"]
