# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
Dmfa::Application.config.secret_key_base = '6b02e6d85b976e394d463365a02195ed0a5ca4595081f296bf617c9c38af1fa4f1a8679742e45c3afa112a68e70373d57b854122e4c3da9c7421ec67d7583ad9'
