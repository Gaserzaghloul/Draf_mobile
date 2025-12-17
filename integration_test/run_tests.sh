#!/bin/bash

# ==============================================================================
# BEACON App Automation Test Script
# 
# Features:
# 1. Checks for connected Android devices.
# 2. Auto-launches an Emulator if no device is found.
# 3. Records the screen during tests.
# 4. Runs Integration Tests.
# 5. Generates an HTML Report with Video and Logs.
# ==============================================================================

# ----------------- Configuration -----------------
OUTPUT_DIR="automation_test"
LOG_FILE="$OUTPUT_DIR/test_log.txt"
VIDEO_FILENAME="test_recording.mp4"
HOST_VIDEO_PATH="$OUTPUT_DIR/$VIDEO_FILENAME"
HTML_REPORT="$OUTPUT_DIR/report.html"

# Ensure output directory exists
if [ -d "$OUTPUT_DIR" ]; then
    rm -rf "$OUTPUT_DIR"
fi
mkdir -p "$OUTPUT_DIR"

echo "=========================================="
echo "      BEACON Automation Test Suite        "
echo "=========================================="
echo "Output Directory: $OUTPUT_DIR"

# ----------------- 1. Device Setup -----------------
echo ""
echo "[STEP 1] Checking Device Status..."

DEVICE_ID=$(adb devices | grep -v "List of devices attached" | awk '{print $1}' | head -n 1)

if [ -z "$DEVICE_ID" ]; then
    echo "⚠️  No connected devices found."
    echo "🔹 Attempting to launch Android Emulator..."
    
    # Check if emulator command exists
    EMULATOR_CMD="/Users/gaserzaghlol/Downloads/emulator2/emulator"
    if [ ! -f "$EMULATOR_CMD" ]; then
        echo "❌ Error: Emulator not found at $EMULATOR_CMD"
        echo "   Please check the emulator installation."
        exit 1
    fi

    # List available AVDs
    AVD_LIST=$("$EMULATOR_CMD" -list-avds)
    if [ -z "$AVD_LIST" ]; then
        echo "❌ Error: No AVDs (Android Virtual Devices) found."
        echo "   Please create one in Android Studio."
        exit 1
    fi

    # Pick the first available AVD
    FIRST_AVD=$(echo "$AVD_LIST" | head -n 1)
    echo "🔹 Launching Emulator: $FIRST_AVD"
    
    # Launch emulator in background
    "$EMULATOR_CMD" -avd "$FIRST_AVD" -no-boot-anim -netdelay none -netspeed full &
    EMULATOR_PID=$!
    
    echo "⏳ Waiting for emulator to boot (this may take a few minutes)..."
    adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done;'
    
    echo "✅ Emulator launched and ready."
    
    # Re-fetch Device ID
    DEVICE_ID=$(adb devices | grep -v "List of devices attached" | awk '{print $1}' | head -n 1)
else
    echo "✅ Device connected: $DEVICE_ID"
fi

# ----------------- 2. Build the App -----------------
echo ""
echo "[STEP 2] Building the app..."

# Build the app first (this takes time, don't record this part)
flutter build apk --debug 2>&1 | tee "$LOG_FILE"

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "✅ Build completed"

# ----------------- 3. Run Test with Screen Recording -----------------
echo ""
echo "[STEP 3] Running test with screen recording..."

# Create a background script that will start recording after a delay
# This ensures the app has time to launch before recording starts
cat > /tmp/beacon_record.sh << 'RECORDING_SCRIPT'
#!/bin/bash
# Wait for the app to fully launch and reach ProfilePage (flutter test takes ~60-70s to launch)
sleep 65
# Start recording (25 seconds is enough for our 15-20 second test)
adb shell screenrecord --time-limit 25 /sdcard/test_recording.mp4
RECORDING_SCRIPT

chmod +x /tmp/beacon_record.sh

# Start the recording script in background
/tmp/beacon_record.sh &
RECORDING_PID=$!

echo "🎥 Screen recording will start in 65 seconds (waiting for app to fully load and reach profile page)..."

# Run the integration test (Flutter will handle installation)
flutter test integration_test/app_test.dart -d "$DEVICE_ID" 2>&1 | tee -a "$LOG_FILE"
TEST_EXIT_CODE=${PIPESTATUS[0]}

echo "------------------------------------------"
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "✅ Tests PASSED"
    TEST_STATUS="PASSED"
    STATUS_COLOR="green"
else
    echo "❌ Tests FAILED"
    TEST_STATUS="FAILED"
    STATUS_COLOR="red"
fi

# ----------------- 4. Stop Recording & Pull Artifacts -----------------
echo ""
echo "[STEP 4] Collecting Artifacts..."

# Give recording a moment to finalize
sleep 3

# Kill screenrecord process if still running (the --time-limit usually handles it, but just in case)
adb -s "$DEVICE_ID" shell pkill -INT screenrecord

echo "📥 Pulling video from device..."
# Wait a sec for file to be saved
sleep 2
adb -s "$DEVICE_ID" pull "/sdcard/$VIDEO_FILENAME" "$HOST_VIDEO_PATH" > /dev/null

# Clean up on device
adb -s "$DEVICE_ID" shell rm "/sdcard/$VIDEO_FILENAME"

if [ -f "$HOST_VIDEO_PATH" ]; then
    echo "✅ Video saved to: $HOST_VIDEO_PATH"
else
    echo "⚠️  Warning: Video file not found."
fi

# ----------------- 5. Generate HTML Report -----------------
echo ""
echo "[STEP 5] Generating HTML Report..."

# Read log content for embedding
LOG_CONTENT=$(cat "$LOG_FILE")
TIMESTAMP=$(date)

cat > "$HTML_REPORT" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BEACON Test Report</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 20px; background-color: #f4f4f9; color: #333; }
        .container { max-width: 900px; margin: 0 auto; background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .header { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #eee; padding-bottom: 20px; margin-bottom: 20px; }
        h1 { margin: 0; color: #1E3A8A; }
        .status { font-size: 1.2em; font-weight: bold; padding: 8px 16px; border-radius: 20px; color: white; }
        .status.passed { background-color: #10B981; }
        .status.failed { background-color: #EF4444; }
        .section { margin-bottom: 30px; }
        h2 { color: #374151; border-left: 4px solid #3B82F6; padding-left: 10px; }
        .video-container { text-align: center; background: #000; padding: 20px; border-radius: 8px; }
        video { max-width: 100%; height: auto; border-radius: 4px; }
        .log-container { background: #1F2937; color: #E5E7EB; padding: 15px; border-radius: 8px; overflow-x: auto; font-family: monospace; white-space: pre-wrap; max-height: 400px; overflow-y: auto; }
        .footer { text-align: center; color: #6B7280; font-size: 0.9em; margin-top: 40px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div>
                <h1>BEACON Test Report</h1>
                <p>Run Date: $TIMESTAMP</p>
            </div>
            <span class="status ${STATUS_COLOR}">$TEST_STATUS</span>
        </div>

        <div class="section">
            <h2>Test Execution Video</h2>
            <div class="video-container">
                <video controls>
                    <source src="$VIDEO_FILENAME" type="video/mp4">
                    Your browser does not support the video tag.
                </video>
            </div>
        </div>

        <div class="section">
            <h2>Execution Logs</h2>
            <div class="log-container">$LOG_CONTENT</div>
        </div>

        <div class="footer">
            Generated by BEACON Automation Suite
        </div>
    </div>
</body>
</html>
EOF

echo "✅ Report generated: $HTML_REPORT"
echo ""
echo "=========================================="
echo "          Automation Completed            "
echo "=========================================="
exit $TEST_EXIT_CODE
