# Assetto Corsa Hard Brake Detect

An Assetto Corsa Custom Shaders Patch (CSP) app written in Lua that will display a prompt to the player if a hard brake is detected from telemetry.

## Testing

```bash
lua test/run_tests.lua
```

```bash
LUA_PATH='/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;;' lua5.4 test/run_tests.lua
```

## Package And Test In-Game

1. Build a release folder with only runtime files:

```bash
rm -rf dist/HardBrakeDetect
mkdir -p dist/HardBrakeDetect
cp manifest.ini app.lua dist/HardBrakeDetect/
cp -r lib data dist/HardBrakeDetect/
```

2. Create a zip package (optional):

```bash
cd dist
zip -r HardBrakeDetect.zip HardBrakeDetect
```

3. Install into Assetto Corsa:
- Copy `dist/HardBrakeDetect` to `...\AssettoCorsa\apps\lua\HardBrakeDetect\`
- Ensure these files exist:
  - `...\AssettoCorsa\apps\lua\HardBrakeDetect\manifest.ini`
  - `...\AssettoCorsa\apps\lua\HardBrakeDetect\app.lua`
  - `...\AssettoCorsa\apps\lua\HardBrakeDetect\lib\...`

4. Enable and test:
- In Content Manager/CSP, make sure Lua apps are enabled.
- Start a driving session and enable **Hard Brake Detect** from the right-side app bar.
- Brake hard from speed and confirm the app shows `Hard Brake Detected`.

