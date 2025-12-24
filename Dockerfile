FROM rust:latest

# Install Python and other dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install wasm-tools
RUN cargo install wasm-tools

# Add wasm32 target for Rust
RUN rustup target add wasm32-unknown-unknown

WORKDIR /workspace

# Copy the entire project
COPY sos/ /workspace/sos/

# Step 1: Compile Rust code into .wasm module
RUN cd /workspace/sos && \
    cargo build --target wasm32-unknown-unknown --release

# Step 2: Create component with wasm-tools
RUN wasm-tools component embed \
    /workspace/sos/wit/sos.wit \
    /workspace/sos/target/wasm32-unknown-unknown/release/sos.wasm \
    -o /workspace/sos.e.wasm
RUN wasm-tools component new \
    /workspace/sos.e.wasm \
    -o /workspace/sos.c.wasm

# Step 3: Create Python venv and install wasmtime
RUN python3 -m venv /workspace/venv
RUN /workspace/venv/bin/pip install --upgrade pip && \
    /workspace/venv/bin/pip install wasmtime pytest

COPY use.py /workspace/
# Step 4: Run the verification script
CMD ["/workspace/venv/bin/python", "/workspace/use.py"]
