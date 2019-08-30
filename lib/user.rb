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
  validate :unique_username

  def initialize(username, password = "")
    @username = username
    @password = password
  end

  def save
    return false unless valid?
    
    $redis.multi do
      $redis.sadd("usernames", username)
      $redis.hmset(
        user_key,
        "username",
        username,
        "password", 
        encrypt_password,
        "created_at",
        Time.current.to_i
      )
    end

    return true
  end

  def verify_credentials
    if stored_password.present?
      BCrypt::Password.new(stored_password) == password
    else
      false
    end
  end

  def to_json
    data = $redis.hgetall(user_key).except("password")
    data[:tokens] = user_tokens
    data
  end

  def exists
    $redis.sismember("usernames", username)
  end

  def save_token(token_uuid, expiration_time)
    token_key = "user:#{username}:token:#{token_uuid}"
    expire_at = expiration_time.to_i

    $redis.multi do
      $redis.set(token_key, expire_at)
      $redis.expireat(token_key, expire_at)
    end
  end
  
  private

  def user_token_keys
    keys = []
    $redis.scan_each(match: "user:#{username}:token:*") { |key| keys << key }
    keys
  end

  def user_tokens
    keys = user_token_keys
    values = keys.map { |key| $redis.get(key) } 
    keys.map.with_index do |key, index| 
      { key.gsub!("user:#{username}:token:", '') => values[index] }
    end
  end

  def stored_password
    $redis.hget(user_key, "password")
  end

  def unique_username
    errors.add(:username, USERNAME_UNIQUE_MESSAGE) if exists
  end

  def user_key
    "username:#{username}"
  end

  def encrypt_password
    BCrypt::Password.create(password)
  end
end