# Robot Framework test suite

This folder contains the Robot Framework automation for validating the MDS note generator in `MDS_html.html`.

## Contents

- `tests/mDS.robot` — browser validation suite for Chrome, Firefox, and Edge
- `tests/template_case.robot` — reusable pairwise-case template
- `tests/generated/` — generated pairwise test cases
- `../tools/generate_pairwise.py` — generates pairwise combinations from the parameter set
- `../tools/run_pabot.sh` — convenience wrapper to generate and run the generated suite with `pabot`

## Scope

The suite verifies that the web form:

- enforces the valid age range of 18 to 110
- enforces valid ARD/date constraints
- truncates long resident name and DPOA values to 30 characters
- blocks invalid combinations such as below-min age, above-max age, and future ARD values
- verifies the generated note output appears correctly for valid data

## Prerequisites

From the repo root:

```bash
source .venv/bin/activate
export PATH="$(pwd)/drivers:$PATH"
```

Required browser drivers are expected under `drivers/`:

- `chromedriver`
- `geckodriver`
- `msedgedriver`

Firefox ESR is also supported via the repo helper scripts if needed.

## Run the main Robot suite

```bash
cd /home/zieglarnatt/Workspace/healthcareTools
source .venv/bin/activate
export PATH="$(pwd)/drivers:$PATH"
robot robotFrameworkTests/tests/mDS.robot
```

Or, if you want to run the generated pairwise suite:

```bash
bash tools/run_pabot.sh --processes 6 --outputdir results_generated
```

## Generate pairwise cases

```bash
cd /home/zieglarnatt/Workspace/healthcareTools
source .venv/bin/activate
python3 tools/generate_pairwise.py
```

This writes Robot test cases into:

```text
robotFrameworkTests/tests/generated/
```

## Notes

- The suite is intentionally browser-specific and tags cases by browser and purpose.
- The HTML page under the repo root is referenced as a file URL from the Robot tests.
- The script paths are relative to the repo root, not to the individual test file location.

## Useful tags

Examples used in the suite:

- `browser:chrome`
- `browser:firefox`
- `browser:edge`
- `regression_test`
- `happy_path`
- `smoke_test`
- `pairwise`

## Troubleshooting

If browser startup fails:

1. Verify the driver binary exists in `drivers/`
2. Verify `PATH` includes the repo's `drivers` directory
3. Confirm the browser binary is present and executable
4. Try a single-browser run before parallelized runs

For example:

```bash
robot -d results_single robotFrameworkTests/tests/mDS.robot
```
