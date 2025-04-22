FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates
ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh
ENV PATH="/root/.local/bin/:$PATH"
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Change the working directory to the `app` directory
WORKDIR /app

# Install dependencies

RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project

# Copy the project into the image
ADD . /app

# Sync the project
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen

FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS service
EXPOSE 80

# RUN apt-get update && apt-get install curl -y
# RUN addgroup --gid 10000 service && \
#     adduser --uid 10000 --ingroup service service

COPY --from=builder --chown=service:service /app /app

WORKDIR /app
# USER service

CMD ["/app/.venv/bin/uvicorn", "main:app", "--port", "8080"]
