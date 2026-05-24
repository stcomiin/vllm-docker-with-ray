# vllm-docker-with-ray

Docker images that layer [Ray](https://www.ray.io/) back onto the official
[vLLM](https://github.com/vllm-project/vllm) and
[SGLang](https://github.com/sgl-project/sglang) inference servers, so their
Ray-based distributed (multi-node) execution works out of the box.

vLLM dropped Ray as a default dependency in
[vllm-project/vllm#36170](https://github.com/vllm-project/vllm/pull/36170).
These images reinstall a compatible Ray on top of the official CUDA 12.9
(`cu129`) base images.

## Images

| File               | Base image                        | Ray                  |
| ------------------ | --------------------------------- | -------------------- |
| `Dockerfile`       | `vllm/vllm-openai:v0.20.1-cu129`  | `ray[cgraph]>=2.48.0`|
| `sglang-dockerfile`| `lmsysorg/sglang:v0.5.11-cu129`   | `ray[default]==2.55.1`|

- The vLLM image uses the `[cgraph]` extra required by vLLM's Ray compiled-graph
  executor, and runs an `import ray` check at build time to fail fast.
- The SGLang image pins Ray exactly to avoid Ray ↔ `torch.distributed` drift.

## Build

```bash
# vLLM + Ray
docker build -t vllm-ray .

# SGLang + Ray
docker build -f sglang-dockerfile -t sglang-ray .
```

### Build args

Override versions without editing the files:

```bash
docker build --build-arg RAY_VERSION=">=2.48.0" -t vllm-ray .
docker build -f sglang-dockerfile --build-arg SGLANG_VERSION=v0.5.11-cu129 --build-arg RAY_VERSION=2.55.1 -t sglang-ray .
```

## Run

Both images keep their upstream entrypoints, so run them exactly as you would
`vllm/vllm-openai` or `lmsysorg/sglang`. Start a Ray cluster
(`ray start --head` / `ray start --address=...`) across your nodes, then launch
the server with the tensor/pipeline-parallel settings that span the cluster.
