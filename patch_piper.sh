#!/bin/bash

# Function to patch the file inside the container
patch_piper_voice() {
    local container_name="piper-tts-rocm"
    
    echo "Patching piper voice.py in container $container_name..."
    
    # Use docker exec to run the sed command inside the container
    docker exec $container_name bash -c '\
        . /app/venv/bin/activate && \
        VOICE_PY=$(pip show piper-tts | grep "Location" | cut -d" " -f2)/piper/voice.py && \
        echo "Patching file: $VOICE_PY" && \
        sed -i "/providers=\[/c\            providers=[\"MIGraphXExecutionProvider\"]," $VOICE_PY && \
        echo "Patch applied successfully!"'
    
    # Check the result
    if [ $? -eq 0 ]; then
        echo "Successfully patched piper voice.py"
    else
        echo "Failed to patch piper voice.py"
        exit 1
    fi
}

# Check if container is running
if docker ps | grep -q "piper-tts-rocm"; then
    patch_piper_voice
else
    echo "Error: piper-tts-rocm container is not running"
    echo "Please start the container first with: ./run_container.sh"
    exit 1
fi 