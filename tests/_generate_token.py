import secrets
import string

# Define the character set for the token (alphanumeric + symbols)
characters = string.ascii_letters + string.digits + string.punctuation

# Generate a 64-character token
token = ''.join(secrets.choice(characters) for i in range(64))

print(token)
