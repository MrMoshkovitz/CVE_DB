from fastapi import FastAPI
import uvicorn
from fastapi.middleware.cors import CORSMiddleware
from app.routes.cve import router as CVERouter
from app.database import VM_PUBLIC_IP

app = FastAPI(
    title="CVE Database API",
    description="An API to manage and retrieve CVE information.",
    version="1.0.0",
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    # allow_origins=[f"http://{VM_PUBLIC_IP}:3000"],  # React frontend URL
    allow_origins=["*"],  # Allow all origins temporarily
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],)

app.include_router(CVERouter, prefix="/cves", tags=["CVEs"])

@app.get("/", tags=["Root"])
async def read_root():
    return {"message": "Welcome to the CVE Database API. Access /cves to interact with CVE data."}

