import os
import socket
import time
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(
    title="aws-eks-cicd API",
    description="Production FastAPI app deployed on AWS EKS",
    version="1.0.0",
)

START_TIME = time.time()


class HealthResponse(BaseModel):
    status: str


class RootResponse(BaseModel):
    message: str
    hostname: str
    pod_ip: str
    uptime_seconds: float
    version: str


@app.get("/health", response_model=HealthResponse, tags=["ops"])
def health():
    """Liveness probe — Kubernetes uses this to know the pod is alive."""
    return {"status": "ok"}


@app.get("/ready", response_model=HealthResponse, tags=["ops"])
def ready():
    """Readiness probe — Kubernetes uses this before routing traffic to the pod."""
    return {"status": "ready"}


@app.get("/", response_model=RootResponse, tags=["app"])
def root():
    """
    Main endpoint. Returns pod identity info — useful during load testing
    to confirm multiple pods are serving traffic.
    """
    return {
        "message": "Hello from EKS - deployed via CI/CD",,
        "hostname": socket.gethostname(),   # pod name in Kubernetes
        "pod_ip": socket.gethostbyname(socket.gethostname()),
        "uptime_seconds": round(time.time() - START_TIME, 2),
        "version": os.getenv("APP_VERSION", "local"),
    }