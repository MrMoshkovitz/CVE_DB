from fastapi import APIRouter, HTTPException, Body, status
from fastapi.encoders import jsonable_encoder
from typing import List
import logging

from app.models.cve import CVEModel
from app.database import cve_collection, cve_helper

logger = logging.getLogger(__name__)
router = APIRouter()

# Create a new CVE entry
@router.post("/", response_description="Add new CVE", response_model=CVEModel)
async def create_cve(cve: CVEModel = Body(...)):
    try:
        cve = jsonable_encoder(cve)
        new_cve = await cve_collection.insert_one(cve)
        created_cve = await cve_collection.find_one({"_id": new_cve.inserted_id})
        if created_cve is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Created CVE not found"
            )
        return cve_helper(created_cve)
    except Exception as e:
        logger.error(f"Error creating CVE: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create CVE: {str(e)}"
        )

@router.get("/", response_description="List all CVEs", response_model=List[CVEModel])
async def list_cves():
    try:
        logger.info("Fetching CVEs from database...")
        cves = []
        async for cve in cve_collection.find():
            try:
                logger.debug(f"Processing CVE document: {cve}")
                cves.append(cve_helper(cve))
            except Exception as e:
                logger.error(f"Error processing CVE: {e}")
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail=f"Error processing CVE: {str(e)}"
                )
        return cves
    except Exception as e:
        logger.error(f"Error in list_cves: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve CVEs: {str(e)}"
        )

# Retrieve a single CVE entry by CVE ID
@router.get("/{cve_id}", response_description="Get CVE by ID", response_model=CVEModel)
async def get_cve(cve_id: str):
    try:
        cve = await cve_collection.find_one({"cve_id": cve_id})
        if cve is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"CVE with ID {cve_id} not found"
            )
        return cve_helper(cve)
    except Exception as e:
        logger.error(f"Error retrieving CVE {cve_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve CVE: {str(e)}"
        )

# Update a CVE entry by CVE ID
@router.put("/{cve_id}", response_description="Update a CVE", response_model=CVEModel)
async def update_cve(cve_id: str, cve: CVEModel = Body(...)):
    cve = {k: v for k, v in cve.dict().items() if v is not None}
    if len(cve) >= 1:
        update_result = await cve_collection.update_one({"cve_id": cve_id}, {"$set": cve})
        if update_result.modified_count == 1:
            updated_cve = await cve_collection.find_one({"cve_id": cve_id})
            if updated_cve is not None:
                return cve_helper(updated_cve)
    existing_cve = await cve_collection.find_one({"cve_id": cve_id})
    if existing_cve is not None:
        return cve_helper(existing_cve)
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"CVE {cve_id} not found")

# Delete a CVE entry by CVE ID
@router.delete("/{cve_id}", response_description="Delete a CVE")
async def delete_cve(cve_id: str):
    delete_result = await cve_collection.delete_one({"cve_id": cve_id})
    if delete_result.deleted_count == 1:
        return {"message": f"CVE {cve_id} deleted successfully"}
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"CVE {cve_id} not found")
