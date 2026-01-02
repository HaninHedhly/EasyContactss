from pydantic import BaseModel, EmailStr
from typing import Optional

# === SCHÉMAS UTILISATEUR ===
class UserBase(BaseModel):
    email: EmailStr

class UserCreate(UserBase):
    password: str

class UserLogin(UserBase):
    password: str

class User(UserBase):
    id: int
    
    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None

# === SCHÉMAS CONTACT ===
class ContactBase(BaseModel):
    name: str
    phone: str
    email: str

class ContactCreate(ContactBase):
    pass

class ContactUpdate(ContactBase):
    pass

class Contact(ContactBase):
    id: int
    user_id: int
    
    class Config:
        from_attributes = True