FROM ruby:2.5.3

COPY Gemfile Gemfile.lock ./
EXPOSE 3000

ENV RAILS_ENV production
RUN bundle install

COPY . ./

ENTRYPOINT [ "bundle", "exec" ]
CMD [ "rails", "s", "-p", "3000", "-b", "0.0.0.0" ]