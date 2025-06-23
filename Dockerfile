# ----- Base OS + CUDA runtime ---------------------------------------------
FROM nvidia/cuda:12.4.0-runtime-ubuntu22.04

# ----- System packages -----------------------------------------------------
RUN apt update -y && \
    apt install -y git ffmpeg aria2 wget python3.11 python3.11-venv python3-pip && \
    rm -rf /var/lib/apt/lists/*

# ----- Python + PyTorch ----------------------------------------------------
RUN pip3 install --upgrade pip && \
    pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# ----- Clone & install apps ------------------------------------------------
WORKDIR /workspace

# ----- AUTOMATIC1111 -------------------------------------------------------
RUN git clone --depth=1 https://github.com/AUTOMATIC1111/stable-diffusion-webui a1111

# install only the pieces we need (Torch is already in the image)
RUN pip install fastapi==0.90.1

# pre-built xformers wheel that matches Torch 2.3 + CUDA 12.4
RUN pip install xformers==0.0.29.post1 --index-url https://download.pytorch.org/whl/cu124

# 2. FaceFusion (live face-swap)
RUN git clone --depth=1 https://github.com/FaceFusion/FaceFusion.git facefusion && \
    pip install -r facefusion/requirements.txt

# 3. Retrieval-based Voice Conversion (RVC)
RUN git clone --depth=1 https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI.git rvc && \
    pip install -r rvc/requirements.txt

# 4. Whisper WebUI
RUN git clone --depth=1 https://github.com/aadnk/whisper-webui.git whisper && \
    pip install -r whisper/requirements.txt

# ----- Model auto-fetcher --------------------------------------------------
COPY fetch_models.sh /usr/local/bin/fetch_models.sh
RUN chmod +x /usr/local/bin/fetch_models.sh

# ----- Gradio hub launcher -------------------------------------------------
COPY launcher.py /workspace/launcher.py

EXPOSE 7000 7860 7870 7900 8899 5901
CMD [ "python3", "/workspace/launcher.py" ]
