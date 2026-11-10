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
#
# The wit_bindgen::generate! macro already embeds the WIT world into the
# core module as a "component-type" custom section, so sos.wasm can be
# turned into a component directly.
#
# For toolchains that do NOT embed the WIT metadata themselves, an extra
# step is needed first, and `component new` is then run on its output:
#
#   RUN wasm-tools component embed \
#       /workspace/sos/wit/sos.wit \
#       /workspace/sos/target/wasm32-unknown-unknown/release/sos.wasm \
#       -o /workspace/sos.e.wasm
#   RUN wasm-tools component new \
#       /workspace/sos.e.wasm \
#       -o /workspace/sos.c.wasm
RUN wasm-tools component new \
    /workspace/sos/target/wasm32-unknown-unknown/release/sos.wasm \
    -o /workspace/sos.c.wasm

# Step 3: Create Python venv and install wasmtime
RUN python3 -m venv /workspace/venv
RUN /workspace/venv/bin/pip install --upgrade pip && \
    /workspace/venv/bin/pip install wasmtime pytest

COPY test_sos.py /workspace/
# Step 4: Run the tests
CMD ["/workspace/venv/bin/pytest", "-v", "/workspace/test_sos.py"]
