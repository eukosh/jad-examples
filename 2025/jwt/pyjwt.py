import jwt

secret_key = "my_super_secret_key"
ALGORITHM = "HS256"

payload_pyjwt = {
    "user_id": 123,
    "username": "test_user",
    "role": "admin",
}

# PyJWT automatically handles the encoding, signing, and formatting
pyjwt_token = jwt.encode(payload_pyjwt, secret_key, algorithm=ALGORITHM)

print("\nFinal PyJWT Created Token:\n", pyjwt_token)
