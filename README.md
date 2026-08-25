# healthcareTools

A lightweight collection of healthcare documentation utilities built as static HTML, CSS, and JavaScript assets. The repository is intended to support faster, more consistent completion of common clinical writing tasks, especially MDS note drafting and related documentation workflows.

## Included tools

- `MDS_html.html`: a browser-based MDS note generator used to create formatted documentation based on resident demographics, assessment selections, and screening inputs.

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

Open `MDS_html.html` directly in a browser, or serve the folder locally with Python if you prefer a simple local host:

```bash
python3 -m http.server 8000 --directory healthcareTools >/tmp/serve.log 2>&1 & echo $!
```

Then open the page in a browser at:

```text
http://localhost:8000/MDS_html.html
```
