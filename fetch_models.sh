#!/usr/bin/env bash
set -e
DST=/workspace/models
mkdir -p "$DST"

# --- helper function ---
download () {
  FILE="$DST/$2"
  [ -f "$FILE" ] && echo "✔ $2 exists" && return
  echo "⬇  $2"
  aria2c -x16 -s16 -k5M -o "$FILE" "$1"
}

# --- Civitai IDs (realism + extras) ---
for ID in 398281 401187 322579 302182 350633; do
  download "https://civitai.com/api/download/models/$ID" "${ID}.safetensors"
done

# --- Hugging Face models ---
HF_MODELS=(
  "runwayml/wan-2-any@*.safetensors"
  "ByteDance/AnimateDiff-Motion_L@motion_l.safetensors"
  "stabilityai/sdxl-refiner-1.0@sdxl_refiner_1.0.safetensors"
)

for LINE in "${HF_MODELS[@]}"; do
  REPO=${LINE%@*}; FILE=${LINE#*@}
  [ -f "$DST/$FILE" ] && echo "✔ $FILE exists" && continue
  echo "⬇  $FILE (HF)"
  huggingface-cli download "$REPO" "$FILE" --local-dir "$DST" --resume-download --token "$HF_TOKEN"
done
