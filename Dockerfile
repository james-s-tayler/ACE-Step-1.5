FROM nvidia/cuda:12.8.0-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3.11 \
        python3.11-venv \
        python3.11-dev \
        build-essential \
        git \
        curl \
        ca-certificates \
        libsndfile1 \
        ffmpeg \
    && rm -rf /var/lib/apt/lists/*

RUN python3.11 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /app

COPY requirements.txt pyproject.toml README.md /app/
COPY acestep /app/acestep

RUN pip install --upgrade pip setuptools wheel \
    && pip install --extra-index-url https://download.pytorch.org/whl/cu128 -r requirements.txt \
    && pip install -e . --no-deps

ENV ACESTEP_API_HOST=0.0.0.0 \
    ACESTEP_API_PORT=8001 \
    ACESTEP_API_LOG_LEVEL=info

EXPOSE 8001

CMD ["uvicorn", "acestep.api_server:app", "--host", "0.0.0.0", "--port", "8001", "--workers", "1", "--log-level", "info"]
