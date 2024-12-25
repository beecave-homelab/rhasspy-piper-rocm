#!/bin/bash

# Test the TTS functionality inside the container
docker exec -it $(docker-compose ps -q piper-tts-rocm) \
    bash -c "echo 'Piper TTS with AMD GPU is running successfully!' | \
    piper --model en_US-lessac-medium --output-raw | aplay -r 22050 -f S16_LE -t raw" 