# Troy AI Workbench (L40S)

This repo contains everything you need to build an **all‑in‑one** Docker image
for Stable‑Diffusion XL, FaceFusion live face‑swap, RVC voice cloning,
Whisper transcription, and a Gradio hub—pre‑tuned for a RunPod **L40 S 48 GB**.

## Build

```bash
docker build -t beasthavoc/ai-workbench:latest .
```

## Push to Docker Hub

```bash
docker login
docker push beasthavoc/ai-workbench:latest
```

## RunPod launch settings

| Field                | Value                           |
|----------------------|---------------------------------|
| **Container Image**  | `docker.io/beasthavoc/ai-workbench:latest` |
| **Ports**            | `7000,7860,7870,7900,8899,5901` |
| **Volume**           | Mount `/workspace/models` (100 GB) |
| **Env Vars**         | `HF_TOKEN=<your token>`<br>`CIVITAI_API_KEY=<optional>` |

After the first boot (models will auto‑download once) visit
**https://<POD_URL>/proxy/7000** to access the hub.
