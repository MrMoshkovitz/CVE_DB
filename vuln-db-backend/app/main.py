from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException
import uvicorn
from fastapi.middleware.cors import CORSMiddleware
from app.routes.cve import router as CVERouter
from app.database import Database
from app.middleware.error_handler import ErrorHandlerMiddleware
from app.middleware.rate_limiter import RateLimitMiddleware

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    await Database.connect_db()
    yield
    # Shutdown
    await Database.close_db()

app = FastAPI(
    title="CVE Database API",
    description="An API to manage and retrieve CVE information.",
    version="1.0.0",
    lifespan=lifespan,
    redirect_slashes=False
)

# Add middlewares
app.add_middleware(
    RateLimitMiddleware,
    rate_limit=100,
    time_window=60
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins temporarily
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize error handler middleware
ErrorHandlerMiddleware(app)

app.include_router(CVERouter, prefix="/cves", tags=["CVEs"])

@app.get("/", tags=["Root"])
async def read_root():
    return {"message": "Welcome to the CVE Database API. Access /cves to interact with CVE data."}

@app.get("/health", tags=["Health"])
async def health_check():
    try:
        await Database.client.server_info()
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        raise HTTPException(
            status_code=503,
            detail=f"Service unhealthy: {str(e)}"
        )

if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)


