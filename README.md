# PIPER-TTS-ROCM

Build a Dockerized environment for `piper-tts-rocm` to enable AMD GPU acceleration for Piper TTS using ROCm 6.1.2 and ONNX Runtime.

## Summary

This project creates a GPU-enabled Dockerized setup for Piper TTS with AMD ROCm support. It uses multi-stage Docker builds, a `docker-compose.yaml` file for easy orchestration, and environment variables for GPU configuration. The setup supports AMD GPU acceleration, including RX6600 or similar GPUs.

## Project Structure

```plaintext
piper-tts-rocm/
│
├── Dockerfile
├── docker-compose.yaml
├── run_container.sh
├── test_tts.sh
└── README.md
```

## Setup Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/piper-tts-rocm.git
   cd piper-tts-rocm
   ```

2. Make the scripts executable:
   ```bash
   chmod +x run_container.sh test_tts.sh
   ```

3. Build and start the container:
   ```bash
   ./run_container.sh
   ```

4. Test the TTS functionality:
   ```bash
   ./test_tts.sh
   ```

## Requirements

- Docker and Docker Compose
- AMD GPU with ROCm support
- Linux system with ROCm drivers installed

## Configuration

The project uses the following key configurations:

- ROCm version: 6.1.2
- ONNX Runtime: 1.17.0
- Python packages: numpy 1.26.4, protobuf 4.25.3
- GPU configuration via environment variables in docker-compose.yaml

## Troubleshooting

- Check Docker logs:
  ```bash
  docker-compose logs
  ```

- Ensure `/dev/kfd` and `/dev/dri` are accessible
- Verify ROCm installation on the host system
- Check GPU compatibility with ROCm 6.1.2

## Notes

- The container maps the `./models` directory for TTS model storage
- GPU access is configured through Docker devices and group permissions
- The setup includes ALSA utils for audio output

## License

This project is open-source and available under the MIT License. 