#!/bin/bash

# Activate the virtual environment
. /app/venv/bin/activate

# Create output directory if it doesn't exist
mkdir -p /app/output

# Function to run TTS test
run_tts_test() {
    local model=$1
    local timestamp=$(date +%d-%m-%Y_%H-%M)
    local model_name=$(basename "$model")
    local output_file="/app/output/${model_name}_${timestamp}.wav"
    
    echo "Testing Piper TTS with AMD GPU using model: $model_name"
    echo "Piper TTS with AMD GPU is running successfully!" | \
        piper --model "$model" --output_file "$output_file"

    echo "Audio file generated at $output_file"
}

# Run the test with different models
run_tts_test "en_US-lessac-medium"

# Keep the container running
exec "$@" 
sleep 60