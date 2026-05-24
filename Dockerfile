FROM vllm/vllm-openai:v0.20.1-cu129

# Re-add Ray, which was removed as a default dependency in
# https://github.com/vllm-project/vllm/pull/36170
# [cgraph] extra is required for vLLM's Ray-based distributed execution.
ARG RAY_VERSION=">=2.48.0"
RUN pip install --no-cache-dir "ray[cgraph]${RAY_VERSION}"

# Sanity check at build time — fail fast if the install is broken.
RUN python3 -c "import ray; print('ray', ray.__version__)"