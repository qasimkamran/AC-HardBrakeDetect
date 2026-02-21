# Assetto Corsa Hard Brake Detect

An Assetto Corsa Custom Shaders Patch (CSP) app written in Lua that will display a prompt to the player if a hard brake is detected from telemetry that the game provides.

## Requirements

- Assetto Corsa (PC)
- Custom Shaders Patch (CSP) with Lua apps enabled
- Content Manager (recommended for enabling and managing CSP apps)
- Lua 5.4+ for running the test suite locally
- `luaunit` available on your Lua path (tests use `require("luaunit")`)

## Installation

1. Build the app package:
```bash
rm -rf dist/HardBrakeDetect
mkdir -p dist/HardBrakeDetect
cp manifest.ini HardBrakeDetect.lua icon.png dist/HardBrakeDetect/
cp -r lib dist/HardBrakeDetect/
```

2. Install the app into Assetto Corsa:
- Copy `dist/HardBrakeDetect` to `...\AssettoCorsa\apps\lua\`
- Final path should be `...\AssettoCorsa\apps\lua\HardBrakeDetect\`

3. Enable the app:
- Open Content Manager
- Ensure CSP Lua apps are enabled
- Enable **Hard Brake Detect** in the app list / right-side app bar

## Demo

[Watch demo video](./demo.mp4)

*The video above shows a driver pulling into a parking lot and braking hard a few seconds after accelerating. The prompt updates accordingly to reflect this. However, when the braking is gradual, the prompt is not displayed as expected.*

You can ignore most of the headings below if you are not forking the repository or attempting to submit PRs.

Design document  - [[NOTES.md]]

## Configuration

The app is currently configured through source constant config tables per file (not an external config file).

### Detection Thresholds

Defined in `lib/detector.lua` under `HardBrakeConfig`:

- `MIN_EXPECTED_SAMPLE_RATE_HZ = 5`: minimum telemetry sampling density expected while braking.
- `CHANGE_IN_SPEED_THRESHOLD = 1.0`: minimum speed drop across the sample window (km/h).
- `PEAK_DECEL_THRESHOLD = -3.0`: required peak deceleration threshold (m/s^2).
- `DECEL_MIN_CONSECUTIVE_SAMPLES = 2`: minimum consecutive samples at or below `PEAK_DECEL_THRESHOLD`.

### Sample Window

Defined in `HardBrakeDetect.lua`:

- `WINDOW_SAMPLE_COUNT = 4`: number of most recent braking samples used for each evaluation.

### Debug Logging

Defined in `HardBrakeDetect.lua` and `lib/logger.lua`:

- `Enable Debug Logging` checkbox toggles runtime CSV logging.
- `LOG_DIR = "../log/"` controls log output path.

### App Window Settings

Defined in `manifest.ini`:

- `SIZE = 300, 150`
- `FLAGS = FIXED_SIZE`

## In-Game Validation

1. Install into Assetto Corsa:
- Copy `dist/HardBrakeDetect` to `...\AssettoCorsa\apps\lua\`
- Ensure these files exist:
  - `...\AssettoCorsa\apps\lua\HardBrakeDetect\manifest.ini`
  - `...\AssettoCorsa\apps\lua\HardBrakeDetect\HardBrakeDetect.lua`
  - `...\AssettoCorsa\apps\lua\HardBrakeDetect\icon.png`
  - `...\AssettoCorsa\apps\lua\HardBrakeDetect\lib\...`

2. Enable and test:
- In Content Manager/CSP, make sure Lua apps are enabled.
- Start a driving session and enable **Hard Brake Detect** from the right-side app bar.
- Brake hard from speed and confirm the app shows `Hard Brake Detected`.

## Project Structure

```text
.
├── HardBrakeDetect.lua
├── manifest.ini
├── icon.png
├── demo.mp4
├── README.md
├── NOTES.md
├── lib/
│   ├── detector.lua
│   ├── telemetry.lua
│   ├── parser.lua
│   ├── logger.lua
│   └── ui.lua
├── test/
│   ├── run_tests.lua
│   ├── test_detector.lua
│   ├── test_telemetry.lua
│   ├── test_parser.lua
│   ├── test_logger.lua
│   └── test_ui.lua
├── data/
│   └── mock_telemetry.csv
├── log/
└── .github/
```

## License

MIT License. See `LICENSE`.
