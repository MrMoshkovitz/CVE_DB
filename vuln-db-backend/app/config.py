from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    MONGO_DETAILS: str = "mongodb://127.0.0.1:27017/vuln_db"
    MONGO_DB_NAME: str = "vuln_db"
    CVE_COLLECTION_NAME: str = "cves"
    VM_PUBLIC_IP: str = "localhost"
    
    class Config:
        env_file = ".env"

settings = Settings()

# To use this in database.py:
# from app.config import settings
# print(settings.MONGO_DETAILS)
# print(settings.MONGO_DB_NAME)
# print(settings.CVE_COLLECTION_NAME)
# print(settings.VM_PUBLIC_IP)