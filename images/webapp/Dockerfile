FROM ruby:2.2.7

RUN apt-get update && \
    apt-get install -y net-tools
        

COPY /app/Gemfile /app/Gemfile
RUN cd /app; bundle install

COPY /app/app.rb /app/app.rb
COPY /app/job.rb /app/job.rb

EXPOSE 8090
CMD ["ruby", "/app/app.rb"]
