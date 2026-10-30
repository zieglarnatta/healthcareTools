Cypress MDS HTML tests

Quick start

Use the provided wrapper script to check whether a local HTTP server is already running, and only start one if needed before running Cypress.

From the repo root:

```bash
cd /home/zieglarnatt/Workspace/healthcareTools
chmod +x cypressTest/start-cypress.sh
./cypressTest/start-cypress.sh
```

What the wrapper does:

- Checks `http://localhost:8000/MDS_activity_note.html` and `http://localhost:8000/MDS_html.html`
- If the page responds, it reuses the existing server
- If the page does not respond, it starts:

```bash
python3 -m http.server 8000
```

- Then it runs Cypress with `baseUrl=http://localhost:8000`

Usage options

Run all Cypress specs:

```bash
./cypressTest/start-cypress.sh
```

Run a single spec:

```bash
SPEC="cypress/e2e/activity_note_smoke.cy.js" ./cypressTest/start-cypress.sh
```

Use a different port:

```bash
PORT=8080 ./cypressTest/start-cypress.sh
```

Manual setup (if you prefer to start the server yourself)

1. From the repository root, serve the files on a local HTTP server (required):

```bash
cd /home/zieglarnatt/Workspace/healthcareTools
python3 -m http.server 8000
```

2. Install dependencies:

```bash
cd cypressTest
npm install
```

3. Open Cypress interactively:

```bash
npx cypress open # or npm run cypress:open
```

4. Run headless tests:

```bash
npx cypress run --config baseUrl=http://localhost:8000
```

Notes

- The app is expected to be available at `http://localhost:8000/MDS_html.html` for the older MDS HTML tests.
- The activity-note page is available at `http://localhost:8000/MDS_activity_note.html`.
- If you prefer another port, start the server on that port and pass `--config baseUrl=http://localhost:PORT` to Cypress.

Generating pairwise fixture from Robot-generated cases

From the repo root run the generator to create `cypress/fixtures/pairwise_cases.json`:

```bash
cd cypressTest
node scripts/generate_pairwise_fixture.js
```

After generating the fixture, run the pairwise tests with:

```bash
npx cypress run --spec "cypress/e2e/pairwise.cy.js" --config baseUrl=http://localhost:8000
```

