from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Optional
import logging

logger = logging.getLogger(__name__)

class ErrorResponse(BaseModel):
    status_code: int
    message: str
    details: Optional[str] = None

class ErrorHandlerMiddleware:
    def __init__(self, app: FastAPI):
        @app.exception_handler(HTTPException)
        async def http_exception_handler(request: Request, exc: HTTPException):
            logger.error(f"HTTP Exception: {exc.detail}")
            return JSONResponse(
                status_code=exc.status_code,
                content=ErrorResponse(
                    status_code=exc.status_code,
                    message=exc.detail,
                ).dict()
            )

        @app.exception_handler(Exception)
        async def general_exception_handler(request: Request, exc: Exception):
            logger.error(f"Unhandled Exception: {str(exc)}")
            return JSONResponse(
                status_code=500,
                content=ErrorResponse(
                    status_code=500,
                    message="Internal server error",
                    details=str(exc)
                ).dict()
            ) 