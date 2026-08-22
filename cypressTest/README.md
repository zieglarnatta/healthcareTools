Cypress MDS HTML tests

Setup

1. From the repository root serve the files on a local HTTP server (required):

```bash
# from healthcareTools/
python3 -m http.server 8000
```

2. Install dependencies and open Cypress:

```bash
cd cypressTest
npm install
npx cypress open # or npm run cypress:open
```

Run headless:

```bash
npx cypress run --config baseUrl=http://localhost:8000
```

Notes

- Tests assume the site is available at `http://localhost:8000/MDS_html.html`.
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

