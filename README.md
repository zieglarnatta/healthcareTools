# healthcareTools

A small collection of lightweight HTML + JavaScript utilities to assist with common healthcare documentation tasks. These tools are intended to speed up writing standard notes and reports by generating consistent, copyable, and printable text from a small set of inputs.

## Included tools

- `MDS_html.html`: A web-based MDS (Minimum Data Set) note generator for common MDS note types. See details below.

## `MDS_html.html` — what it does

`MDS_html.html` is a single-file HTML/JS tool that generates a formatted MDS note based on user inputs. The page provides a compact form for entering resident information and clinical screening results, then generates a plain-text note you can copy, print, or clear.

### Inputs

- **Note Type**: dropdown with options such as Admission, Quarterly, Annual, Significant Changes.
- **Resident Name**: free-text input for the resident's preferred name.
- **Age**: numeric input for the resident's age.
- **ARD (Assessment Reference Date)**: date input. The displayed output uses `MM/DD/YY` formatting (year shown as last two digits).
- **DPOA**: free-text input for the decision-maker / power of attorney name.
- **Orientation**: dropdown with prewritten cognition/orientation sentences.
	- Special behavior: when `Orientation` is set to "Resident declined to participate in BIMS assessment.", the `BIMS` field is automatically set to the declined option and locked (see below).
- **PHQ Result**: dropdown with PHQ scoring phrase options to describe depressive symptom severity.
- **Behavior**: dropdown with behavior summary phrases.
- **Care Conference**: dropdown to note whether a care conference was offered/held/declined.
- **POLST**: dropdown for code status / POLST entries.

### Orientation ↔ BIMS behavior

- The `Orientation` and `BIMS` fields are linked to prevent inconsistent selections.
- If `Orientation` is exactly `Resident declined to participate in BIMS assessment.`, the `BIMS` dropdown will be auto-selected to `Resident declined to participate in assessment. SW proceeded to staff interviews.` and the `BIMS` control is temporarily disabled so users cannot change it.
- In all other cases the specific "declined" option in the `BIMS` dropdown is disabled (not selectable) to avoid mismatched entries; if it was previously selected it will be cleared when `Orientation` changes.
- The `BIMS` selector is rendered on its own full-width row and is auto-resized at load/resize to display the longest option without truncation.

### How BIMS appears in the generated note

- The generated note always includes the `Orientation` sentence followed immediately by a BIMS sentence in the `COGNITION` section, for example:

	Orientation text
	SW approached <name> to complete the BIMS assessment, <BIMS selection>
	SW will continue to monitor for any changes in cognition and adjust the care plan accordingly.

### Final output

- The tool composes a multiline plain-text MDS note and places it in the **Generated Note** textarea. The textarea auto-resizes to fit the generated content.
- The output is ready to be copied into clinical records, pasted into other documents, or printed directly from the browser.

### Action buttons / functionalities

- **Generate Note** (`Generate Note`): Builds the note from current form values and populates the `Generated Note` textarea. Also auto-resizes the textarea to fit the content.
- **Copy Note** (`Copy Note`): Copies the generated note text to the clipboard. If clipboard.writeText is not available, the tool falls back to a selected-copy approach. A transient on-screen toast confirms success or prompts the user to generate a note first.
- **Print** (`Print`): Opens the browser print dialog (calls `window.print()`), providing a printable rendering of the generated note. The form controls are hidden in the print stylesheet so only the note content is printed.
- **Clear** (`Clear`): Clears all form inputs and the generated note output.

### Location

The file is available at `MDS_html.html` in the repository root of this folder.

---

## Usage example

Open `MDS_html.html` in a browser and complete the form, or simply click **Generate Note** after entering values.