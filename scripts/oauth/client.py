import secrets
import hashlib

## Generate a random string of 32 bytes (256 bits)
#random_bytes = secrets.token_bytes(32) 
## Encode it to a URL-safe base64 string for easier handling
client_secret_raw = secrets.token_urlsafe(32) 
#print(client_secret_raw)

# Hash the raw client secret using SHA256
sha256_hash = hashlib.sha256(client_secret_raw.encode('utf-8')).hexdigest()
print(f"Generated SHA256 Client Secret: {sha256_hash}")
