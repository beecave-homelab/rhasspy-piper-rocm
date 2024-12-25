#!/bin/bash

# Activate the virtual environment
. /app/venv/bin/activate

# Function to run TTS test
run_tts_test() {
    echo "Testing Piper TTS with AMD GPU..."
    echo "Piper TTS with AMD GPU is running successfully!" | \
        piper --model en_US-lessac-medium --output-raw | \
        aplay -r 22050 -f S16_LE -t raw
}

# Run the test
run_tts_test

# Keep the container running
exec "$@" 