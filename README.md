# README

## Synopsis

This tool is intended to be a prototype for a JWT manager service.
The service can create users, give users JWT, and revoke those tokens when
needed. The service has a normal api and an admin api.

## Configuration

run `docker-compose up` from the project root

## Database 

The service uses Redis as a back end. Once running visit /seed to create 10
user on the fly.

## Interaction

Use Postman to interact with the API in a development environment. The postman
collection is found in the root of the repo. You can import it to your postman
and start testing the API.
