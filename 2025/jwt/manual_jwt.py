import base64
import hashlib
import hmac
import json

# HS256 (HMAC using SHA-256)
header = {"alg": "HS256", "typ": "JWT"}

payload = {
    "user_id": 123,
    "username": "test_user",
    "role": "superadmin",
}

header_json = json.dumps(header, separators=(",", ":"))
payload_json = json.dumps(payload, separators=(",", ":"))

encoded_header = (
    base64.urlsafe_b64encode(header_json.encode("utf-8")).decode("utf-8").rstrip("=")
)
encoded_payload = (
    base64.urlsafe_b64encode(payload_json.encode("utf-8")).decode("utf-8").rstrip("=")
)

print("Manually Encoded Header:", encoded_header)
print("Manually Encoded Payload:", encoded_payload)

# Create the Signature using HMAC-SHA256
secret_key = "my_super_secret_key"
message = f"{encoded_header}.{encoded_payload}".encode("utf-8")

# The HMAC function takes the key, the message, and the hash algorithm
signature = hmac.new(secret_key.encode("utf-8"), message, hashlib.sha256).digest()

# Base64url encode the signature
encoded_signature = base64.urlsafe_b64encode(signature).decode("utf-8").rstrip("=")

print("Manually Encoded Signature:", encoded_signature)

manual_jwt = f"{encoded_header}.{encoded_payload}.{encoded_signature}"
print("\nFinal Manually Created JWT:\n", manual_jwt)

# eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMjMsInVzZXJuYW1lIjoidGVzdF91c2VyIiwicm9sZSI6ImFkbWluIn0.0xchd10-FYJ3M9ucXxQr3jiBbCmPY1Z5ON8C9PvZnDs
# eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMjMsInVzZXJuYW1lIjoidGVzdF91c2VyIiwicm9sZSI6ImFkbWluIn0.0xchd10-FYJ3M9ucXxQr3jiBbCmPY1Z5ON8C9PvZnDs

# eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMjMsInVzZXJuYW1lIjoidGVzdF91c2VyIiwicm9sZSI6InN1cGVyYWRtaW4ifQ.0xchd10-FYJ3M9ucXxQr3jiBbCmPY1Z5ON8C9PvZnDs
# eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMjMsInVzZXJuYW1lIjoidGVzdF91c2VyIiwicm9sZSI6InN1cGVyYWRtaW4ifQ.XPuxU-r24dORk-QjC-YFWQb5rPDeqCZAolM-Q-Zf22Y