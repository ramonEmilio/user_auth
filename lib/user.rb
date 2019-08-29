# frozen_string_literal: true

require 'bcrypt'

class User
  include ActiveModel::Validations

  PASSWORD_LENGTH = /\A(?=.{8,})/x
  PASSWORD_NUMBER = /\A(?=.*\d)/x
  PASSWORD_LCASE = /\A(?=.*[a-z])/x
  PASSWORD_UCASE = /\A(?=.*[A-Z])/x
  PASSWORD_SYMBOL = /\A(?=.*[[:^alnum:]])/x

  PASSWORD_LENGTH_MESSAGE = 'Must be at least 8 characters long'
  PASSWORD_NUMBER_MESSAGE = 'Must contain at least one number'
  PASSWORD_LCASE_MESSAGE = 'Must contain at least one lower case character'
  PASSWORD_UCASE_MESSAGE = 'Must contain at least one uppercase character'
  PASSWORD_SYMBOL_MESSAGE = 'Must contain at least one symbol'
  USERNAME_UNIQUE_MESSAGE = "Username already exists"
  
  attr_reader :username, :password

  validates :password, format: { with: PASSWORD_LENGTH, message: PASSWORD_LENGTH_MESSAGE }
  validates :password, format: { with: PASSWORD_NUMBER, message: PASSWORD_NUMBER_MESSAGE }
  validates :password, format: { with: PASSWORD_LCASE, message: PASSWORD_LCASE_MESSAGE }
  validates :password, format: { with: PASSWORD_UCASE, message: PASSWORD_UCASE_MESSAGE }
  validates :password, format: { with: PASSWORD_SYMBOL, message: PASSWORD_SYMBOL_MESSAGE }
  validate :unique_user

  def initialize(username:, password:)
    @username = username
    @password = password
  end

  def save
    return false unless valid?
    
    $redis.multi do
      $redis.sadd("usernames", username)
      $redis.hmset(
        user_key, 
        "encrypted_password", 
        encrypted_password,
        "created_at",
        Time.current.to_i
      )
    end

    return true
  end

  def authenticate
    values = $redis.pipelined do
      $redis.exists(user_key)
      $redis.hget(user_key, "encrypted_password")
    end
    
    values.all? && BCrypt::Password.new(values[1]) == password ? true : false
  end

  def to_json
    { 
      username: username,
      created_at: $redis.hget(user_key, "created_at")
    }
  end

  private

  def unique_user
    errors.add(:username, USERNAME_UNIQUE_MESSAGE) if $redis.sismember("usernames", username)
  end

  def encrypted_password
    BCrypt::Password.create(password)
  end

  def user_key
    "username:#{username}"
  end
end