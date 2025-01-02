from fastapi import Request, HTTPException, status
from fastapi.responses import JSONResponse
import time
from collections import defaultdict
import logging

logger = logging.getLogger(__name__)

class RateLimitMiddleware:
    def __init__(
        self,
        rate_limit: int = 100,  # requests
        time_window: int = 60    # seconds
    ):
        self.rate_limit = rate_limit
        self.time_window = time_window
        self.requests = defaultdict(list)  # IP: [timestamp1, timestamp2, ...]

    async def __call__(self, request: Request, call_next):
        # Get client IP
        client_ip = request.client.host
        
        # Get current timestamp
        now = time.time()
        
        # Clean old requests
        self.requests[client_ip] = [
            timestamp 
            for timestamp in self.requests[client_ip] 
            if timestamp > now - self.time_window
        ]
        
        # Check rate limit
        if len(self.requests[client_ip]) >= self.rate_limit:
            logger.warning(f"Rate limit exceeded for IP: {client_ip}")
            return JSONResponse(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                content={
                    "status_code": 429,
                    "message": "Rate limit exceeded",
                    "details": f"Maximum {self.rate_limit} requests per {self.time_window} seconds"
                }
            )
        
        # Add current request
        self.requests[client_ip].append(now)
        
        # Process the request
        response = await call_next(request)
        return response 