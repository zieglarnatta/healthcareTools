# healthcareTools

A lightweight collection of healthcare documentation utilities built as static HTML, CSS, and JavaScript assets. The repository is intended to support faster, more consistent completion of common clinical writing tasks, especially MDS note drafting and related documentation workflows.

## Included tools

- `MDS_html.html`: a browser-based MDS note generator used to create formatted documentation based on resident demographics, assessment selections, and screening inputs.
- `MDS_activity_note.html`: an activities-focused generator page for creating activity write-ups; open at `/MDS_activity_note.html` in a browser.

## `MDS_html.html` overview

`MDS_html.html` is a static application that assembles a structured MDS note from user-entered values. It collects resident and assessment data, validates required fields, generates a final note in plain text, and then allows the user to copy, print, or clear the result.

### Core inputs

- **Note Type**: selection for note category such as Admission, Quarterly, Annual, or Significant Changes.
- **Resident Name**: resident name input, limited to a safe character set and length.
- **Age**: age input with a valid range check.
- **ARD**: assessment reference date input, validated against a rolling one-year window.
- **DPOA**: decision-maker / power of attorney field.
- **Orientation**: prewritten cognition/orientation statements.
- **BIMS**: BIMS assessment selection used to document the resident's cognitive assessment outcome.
- **PHQ Result**: PHQ scoring text used in mood screening documentation.
- **Behavior**: behavior summary options.
- **Care Conference**: care conference status selection.
- **POLST**: code status / treatment preference selection.

### Orientation and BIMS logic

The `Orientation` and `BIMS` fields are intentionally linked to prevent inconsistent documentation.

- If the `Orientation` field is set to `Resident declined to participate in BIMS assessment.`, the `BIMS` field is automatically set to `resident declined to participate in assessment. SW proceeded to staff interviews.` and the control is temporarily locked.
- In all other selections, the specific declined `BIMS` option is disabled so the user cannot choose a conflicting result.
- If a user changes away from the declined `Orientation` state, any previously selected declined `BIMS` value is cleared to keep the form consistent.
- The `BIMS` control is displayed on its own full-width row and auto-resizes to fit the longest option text without truncation.

### Generated note output

The generated note includes the selected `Orientation` text followed by the BIMS sentence in the `COGNITION` section, for example:
Generated Note
```text
Orientation text
SW approached <name> to complete the BIMS assessment, <BIMS selection>
SW will continue to monitor for any changes in cognition and adjust the care plan accordingly.
```

The final output is written into the **Generated Note** textarea, where the user can review, copy, print, or clear it.

### Action buttons

- **Generate Note**: validates the current form, builds the note, and fills the output text area.
- **Copy Note**: copies the generated note to the clipboard with a fallback copy method when needed.
- **Print**: opens the browser print flow for a cleaner printout of the final note.
- **Clear**: resets the form and clears the generated output.

### Security measures built in

Several protections were added to the current implementation:

- **Content Security Policy (CSP)**: the HTML includes a CSP meta tag that restricts script execution to the current origin, blocks remote connections, and prevents embedded content or external form actions.
- **CSS and JavaScript separation**: the page loads its styling and logic from `static/css/styles.css` and `static/js/mds.js` instead of embedding them directly in the page, which improves maintainability and reduces inline exposure.
- **Input validation**: the JavaScript includes `validName()` and related checks to limit name length, reject unsafe characters, and validate age and ARD values before note generation.

## Local usage

The browser-based tool expects the files to remain together in the same folder structure so the relative paths resolve correctly:

- `MDS_html.html`
- `static/css/styles.css`
- `static/js/mds.js`

Open `MDS_html.html` directly in a browser, or use the provided helper script to start a local Python HTTP server and run Robot tests.

Start the server (serves the repository root by default):

```bash
./scripts/start_http_server.sh
```

Or specify port/host/webroot:

```bash
./scripts/start_http_server.sh 8000 127.0.0.1 /path/to/webroot
```

Then open the page in a browser at:

```text
http://localhost:8000/MDS_html.html
```

## `MDS_activity_note.html` overview

`MDS_activity_note.html` is a focused activities write-up generator implemented as a static HTML application. It assembles an activity-focused note from simple form inputs and provides quick copy/print actions for clinical documentation workflows.

Core inputs and controls

- ARD (assessment/reference date)
- Resident Name and Age
- Cognition (orientation selections)
- Communication and Limited (special needs flags such as HOH, ESL, Dementia)
- Misc (activity preference/status)
- Action buttons: Generate, Copy note, Print, Clear

Output

- A rendered "Generated Write-up" panel shows the assembled note.
- A collapsible "All inputs (raw)" view exposes the JSON/plain-text inputs for inspection or test assertions.

Implementation notes

- Loads styling from `static/css/activities.css` and logic from `static/js/activities.js`.
- Includes a restrictive Content Security Policy meta tag to limit external resources and script execution.
- Designed for direct opening in a browser at `/MDS_activity_note.html` or served via the local HTTP server used by tests.


Running Robot tests (recommended workflow):

1. Start the HTTP server (above).
2. Install drivers and create the venv:

```bash
python3 tools/install_drivers.py
```

3. Run the tests with the project's venv python:

```bash
.venv/bin/python -m robot robotFrameworkTests/tests/mDS.robot
.venv/bin/python -m robot robotFrameworkTests/tests/activities.robot
```

Test artifacts are written to output.xml, log.html, and report.html in the repository root.

## Testing with Cypress and Playwright

Below are step-by-step instructions to run end-to-end tests for the MDS tools.

### Common prerequisite

- Ensure the app is being served from the repository root, typically at http://localhost:8000. You can start a simple server from the repo root with:

```bash
python3 -m http.server 8000
```

### Cypress (cypressTest)

Quick run (recommended wrapper):

1. From the repo root make the wrapper executable and run it:

```bash
chmod +x cypressTest/start-cypress.sh
./cypressTest/start-cypress.sh
```

- The wrapper checks `http://localhost:8000/MDS_activity_note.html` and `http://localhost:8000/MDS_html.html`, starts a minimal Python HTTP server if needed, then runs Cypress with baseUrl pointing at the server.

Manual steps:

1. Start the server (if not using the wrapper):

```bash
python3 -m http.server 8000
```

2. Install dependencies:

```bash
cd cypressTest
npm install
```

3. Run headless tests:

```bash
npx cypress run --config baseUrl=http://localhost:8000
```

4. Open Cypress interactively:

```bash
npx cypress open
```

Options:

- Run a single spec with the wrapper:

```bash
SPEC="cypress/e2e/activity_note_smoke.cy.js" ./cypressTest/start-cypress.sh
```

- Use a different port:

```bash
PORT=8080 ./cypressTest/start-cypress.sh
# or pass --config baseUrl=http://localhost:PORT to npx cypress run
```

Generating pairwise fixture (optional):

```bash
cd cypressTest
node scripts/generate_pairwise_fixture.js
npx cypress run --spec "cypress/e2e/pairwise.cy.js" --config baseUrl=http://localhost:8000
```

### Playwright (playwrightTest)

Quick run:

```bash
cd playwrightTest
npm install
npx playwright install
npm test
```

Notes:

- If Playwright tests need the app, start the HTTP server at http://localhost:8000 before running tests.
- To avoid repeated browser downloads in CI, preinstall Playwright browsers or set PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 when appropriate.

If any step fails, copy the failing command output and open an issue or ask for help with the exact error message.
