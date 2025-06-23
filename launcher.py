import subprocess, threading, gradio as gr, os, signal, sys

# Pull models once (skips if already there)
subprocess.call("/usr/local/bin/fetch_models.sh")

apps = {
    "AUTOMATIC1111": ("cd a1111 && python launch.py --listen --port 7860 --medvram", 7860),
    "FaceFusion":    ("cd facefusion && python run.py --headless --port 7870", 7870),
    "RVC Voice":     ("cd rvc && python infer-web.py --pycmd python --port 7900", 7900),
    "Whisper":       ("cd whisper && python app.py --port 8899", 8899),
}

# start each service in background thread
for cmd, _ in apps.values():
    threading.Thread(target=lambda c=cmd: subprocess.Popen(c, shell=True, preexec_fn=os.setsid)).start()

with gr.Blocks() as hub:
    gr.Markdown("# 🚀 Troy AI Workbench")
    for name, (_, port) in apps.items():
        gr.Button(name).click(None, None, _js=f"() => window.open('/proxy/{port}')")

hub.launch(server_name="0.0.0.0", server_port=7000)
