#######################################################################
#  Troy AI-Workbench - CUDA 12.4 / Torch 2.3 / xformers 0.0.26
#######################################################################

FROM nvidia/cuda:12.4.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /workspace

# --------------------------------------------------------------------
# 1. System packages   (use distro-default Python 3.10)
#    (Added libsndfile1 for the RVC dependency 'soundfile')
# --------------------------------------------------------------------
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        git aria2 wget curl ffmpeg python3 python3-pip libsndfile1 && \
    rm -rf /var/lib/apt/lists/*

# --------------------------------------------------------------------
# 2. PyTorch 2.3.0 & xformers 0.0.26.post1
# --------------------------------------------------------------------
RUN pip3 install --upgrade pip && \
    pip3 install --index-url https://download.pytorch.org/whl/cu121 \
        torch==2.3.0+cu121 torchvision==0.18.0+cu121 torchaudio==2.3.0+cu121 \
        xformers==0.0.26.post1

# Small A1111 runtime dep that isn't in core wheels
RUN pip install fastapi==0.90.1

# --------------------------------------------------------------------
# 3. AUTOMATIC1111 (SDXL / AnimateDiff / Deforum)
# --------------------------------------------------------------------
RUN git clone --depth=1 https://github.com/AUTOMATIC1111/stable-diffusion-webui.git a1111 && \
    # remove torch / xformers pins so it won't re-install or compile them
    sed -i '/torch\|xformers/d' a1111/requirements_versions.txt && \
    pip install --no-cache-dir -r a1111/requirements_versions.txt

# --------------------------------------------------------------------
# 4. FaceFusion (live face-swap) - strip old xformers pin
# --------------------------------------------------------------------
RUN git clone --depth=1 https://github.com/FaceFusion/FaceFusion.git facefusion && \
    sed -i '/xformers/d' facefusion/requirements.txt && \
    pip install --no-cache-dir -r facefusion/requirements.txt

# --------------------------------------------------------------------
# 5. Retrieval-based Voice Conversion (RVC)
#    (remove numpy pin to avoid conflicts)
# --------------------------------------------------------------------
RUN git clone --depth=1 https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI.git rvc && \
    sed -i '/numpy/d' rvc/requirements.txt && \
    pip install --no-cache-dir -r rvc/requirements.txt

# --------------------------------------------------------------------
# 6. Whisper WebUI
# --------------------------------------------------------------------
RUN git clone --depth=1 https://github.com/aadnk/whisper-webui.git whisper && \
    pip install --no-cache-dir -r whisper/requirements.txt

# 7. Model auto-fetcher & launcher
# --------------------------------------------------------------------
COPY fetch_models.sh /usr/local/bin/fetch_models.sh
RUN chmod +x /usr/local/bin/fetch_models.sh

COPY launcher.py /workspace/launcher.py

# --------------------------------------------------------------------
# 8. Networking & start command
# --------------------------------------------------------------------
EXPOSE 7000 7860 7870 7900 8899 5901
CMD ["python3", "/workspace/launcher.py"]
