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
    return {
        "api_name": "CVE Database API",
        "version": "1.0.0",
        "description": "A comprehensive API for managing and retrieving Common Vulnerabilities and Exposures (CVE) information.",
        "base_url": "/cves",
        "endpoints": {
            "GET /cves": {
                "description": "List all CVEs or get a specific CVE",
                "parameters": {
                    "cve": {
                        "type": "string",
                        "optional": True,
                        "example": "CVE-2024-123456",
                        "description": "CVE ID to retrieve a specific vulnerability"
                    }
                },
                "response_format": {
                    "type": "array or single object",
                    "schema": "CVEModel"
                },
                "examples": {
                    "list_all": "/cves",
                    "get_specific": "/cves?cve=CVE-2024-123456"
                }
            },
            "POST /cves": {
                "description": "Create a new CVE entry",
                "content_type": "application/json",
                "required_fields": [
                    "cve_id",
                    "vulnerable_package_name",
                    "vulnerable_package_version_example",
                    # Reference the model fields from CVEModel
                    "assumed_programming_language_from_package",
                    "exploit_execution_context"
                ],
                "response": "Created CVE object"
            },
            "PUT /cves/{cve_id}": {
                "description": "Update an existing CVE entry",
                "parameters": {
                    "cve_id": {
                        "type": "string",
                        "required": True,
                        "example": "CVE-2024-123456"
                    }
                },
                "content_type": "application/json",
                "response": "Updated CVE object"
            },
            "DELETE /cves/{cve_id}": {
                "description": "Delete a CVE entry",
                "parameters": {
                    "cve_id": {
                        "type": "string",
                        "required": True,
                        "example": "CVE-2024-123456"
                    }
                },
                "response": "Success message"
            }
        },
        "data_model": {
            "CVEModel": {
                "id": "string (optional)",
                "cve_id": "string (format: CVE-YYYY-NNNNN)",
                "vulnerable_package_name": "string",
                "vulnerable_package_version_example": "string",
                "assumed_programming_language_from_package": "string",
                "exploit_execution_context": "string",
                # ... reference other fields from CVEModel
            }
        },
        "authentication": "No authentication required currently",
        "rate_limiting": {
            "requests": 100,
            "window": "60 seconds"
        },
        "additional_info": {
            "swagger_docs": "/docs",
            "redoc": "/redoc",
            "content_type": "application/json",
            "cors": "Enabled for all origins (development mode)"
        }
    }

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
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True, proxy_headers=True, forwarded_allow_ips="*")


