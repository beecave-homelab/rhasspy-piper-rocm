#!/bin/bash

# Get container ID
CONTAINER_ID=$(docker-compose ps -q piper-tts-rocm)

# Create timestamp for unique filename
TIMESTAMP=$(date +%d-%m-%Y_%H-%M)
MODEL="en_US-lessac-medium"
OUTPUT_FILE="/app/output/${MODEL}_${TIMESTAMP}.wav"

# Run TTS test inside container
echo "Testing Piper TTS with AMD GPU using model: $MODEL"
docker exec -it $CONTAINER_ID bash -c "echo 'Piper TTS with AMD GPU is running successfully!' | \
    piper --model $MODEL --output_file $OUTPUT_FILE --cuda"

echo "Audio file generated at $OUTPUT_FILE"