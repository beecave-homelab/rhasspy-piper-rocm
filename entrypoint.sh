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
    
    echo "Testing Piper TTS with AMD GPU using model: $model_name"
    
    # Run piper with MIGraphXExecutionProvider for AMD GPU
    local output_file="/app/output/${model_name}_migraphx_${timestamp}.wav"
    echo "Piper TTS with AMD GPU is running successfully!" | \
        piper --model "$model" --output_file "$output_file" --migraphx
    echo "Audio file generated at $output_file"
    
    # Run piper with ROCMExecutionProvider for AMD GPU
    output_file="/app/output/${model_name}_rocm_${timestamp}.wav"
    echo "Piper TTS with AMD GPU is running successfully!" | \
        piper --model "$model" --output_file "$output_file" --rocm
    echo "Audio file generated at $output_file"
    
    # Run piper with CPUExecutionProvider
    output_file="/app/output/${model_name}_cpu_${timestamp}.wav"
    echo "Piper TTS with CPU is running successfully!" | \
        piper --model "$model" --output_file "$output_file"
    echo "Audio file generated at $output_file"
}

# Run the test with different models
run_tts_test "en_US-lessac-medium"

# Wait for 60 seconds
sleep 60

# Keep the container running
exec "$@" 