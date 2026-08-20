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
- **PHQ Result**: dropdown with PHQ scoring phrase options to describe depressive symptom severity.
- **Behavior**: dropdown with behavior summary phrases.
- **Care Conference**: dropdown to note whether a care conference was offered/held/declined.
- **POLST**: dropdown for code status / POLST entries.

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

If you'd like, I can also:

- Turn `MDS_html.html` into a tiny static demo page with a header and example inputs pre-filled.
- Add a short usage example and screenshot to this `README.md`.

