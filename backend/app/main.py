# main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# ================== INITIALISATION DE L'APP ==================
app = FastAPI(
    title="Wishlist Backend API",
    description="API pour gérer les utilisateurs et les contacts",
    version="1.0.0"
)

# ================== CONFIGURATION CORS ==================
# Autoriser toutes les origines localhost en dev (ports dynamiques)
origins = [
    "http://localhost",      # autorise localhost sans port spécifique
    "http://127.0.0.1",      # autorise IP localhost
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],      # pour dev, autorise toutes les origines (incluant tous les ports localhost)
    allow_credentials=True,
    allow_methods=["*"],      # GET, POST, PUT, DELETE...
    allow_headers=["*"],      # autorise tous les headers
)

# ================== IMPORT DES ROUTES ==================
from .routes import auth_routes, contact_routes

# ================== INCLUSION DES ROUTES ==================
app.include_router(auth_routes.router, prefix="/api/auth", tags=["Auth"])
app.include_router(contact_routes.router, prefix="/api/contacts", tags=["Contacts"])

# ================== TEST RAPIDE ==================
@app.get("/")
def read_root():
    return {"message": "Bienvenue sur l'API Wishlist!"}
