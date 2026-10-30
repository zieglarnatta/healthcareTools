function formatISODate(date) {
    var y = date.getFullYear();
    var m = String(date.getMonth() + 1).padStart(2, '0');
    var d = String(date.getDate()).padStart(2, '0');
    return y + '-' + m + '-' + d;
}

// Parse a YYYY-MM-DD string into a local Date (avoids UTC-based shift)
function parseLocalDate(dateString) {
    if (!dateString) return null;
    var parts = dateString.split('-');
    if (parts.length !== 3) return null;
    var y = Number(parts[0]);
    var m = Number(parts[1]);
    var d = Number(parts[2]);
    return new Date(y, m - 1, d);
}

function updateGenerateButtonState() {
    var generateBtn = document.getElementById("generateBtn");
    var ageEl = document.getElementById("age");
    var ardEl = document.getElementById("ard");
    if (!generateBtn) return;

    var invalidAge = false;
    if (ageEl && ageEl.value !== "") {
        var age = Number(ageEl.value);
        invalidAge = age < 18 || age > 110;
    }

    var invalidArd = false;
    if (ardEl) {
        invalidArd = ardEl.dataset.invalid === "true";
        if (!invalidArd && ardEl.value !== "") {
            invalidArd = !isArdValid(ardEl.value);
            if (invalidArd) ardEl.dataset.invalid = "true";
        }
        if (ardEl.value === "") {
            ardEl.dataset.invalid = "false";
        }
    }

    generateBtn.disabled = invalidAge || invalidArd;
    generateBtn.title = invalidAge ? "Age must be between 18 and 110." : invalidArd ? "ARD must be within the last year and not after today." : "";
}

function isArdValid(dateString) {
    if (!dateString) return true;

    var today = new Date();
    today.setHours(0, 0, 0, 0);

    var minDate = new Date(today);
    minDate.setFullYear(minDate.getFullYear() - 1);

    // Use local date parsing to avoid UTC shift
    var current = parseLocalDate(dateString);
    if (!current) return false;

    current.setHours(0, 0, 0, 0);
    return current >= minDate && current <= today;
}

function setDateLimits() {
    var ardEl = document.getElementById("ard");
    if (!ardEl) return;

    var today = new Date();
    today.setHours(0, 0, 0, 0);

    var minDate = new Date(today);
    minDate.setFullYear(minDate.getFullYear() - 1);

    ardEl.min = formatISODate(minDate);
    ardEl.max = formatISODate(today);

    if (ardEl.value && !isArdValid(ardEl.value)) {
        // Mark as invalid but do not clear the user's input; let validation
        // prevent generation and preserve the entered value for review.
        ardEl.dataset.invalid = "true";
        showToast("ARD must be within the last year and not after today.", 3000);
    } else {
        ardEl.dataset.invalid = "false";
    }

    updateGenerateButtonState();
}

function validateFormValues() {
    var ageEl = document.getElementById("age");
    var ardEl = document.getElementById("ard");
    var residentNameEl = document.getElementById("residentName");
    var dpoaEl = document.getElementById("dpoa");

    if (residentNameEl && residentNameEl.value.length > 30) {
        residentNameEl.value = residentNameEl.value.slice(0, 30);
        residentNameEl.focus();
        showToast("Resident name must be 30 characters or less.", 3000);
        return false;
    }

    // Strict whitelist for names (client-side UX only). Server must re-validate.
    if (residentNameEl && residentNameEl.value) {
        if (!validName(residentNameEl.value)) {
            residentNameEl.focus();
            showToast("Resident name contains invalid characters.", 3000);
            return false;
        }
    }

    if (dpoaEl && dpoaEl.value.length > 30) {
        dpoaEl.value = dpoaEl.value.slice(0, 30);
        dpoaEl.focus();
        showToast("DPOA must be 30 characters or less.", 3000);
        return false;
    }

    if (dpoaEl && dpoaEl.value) {
        if (!validName(dpoaEl.value)) {
            dpoaEl.focus();
            showToast("DPOA contains invalid characters.", 3000);
            return false;
        }
    }

    if (ageEl && ageEl.value !== "") {
        var age = Number(ageEl.value);
        if (age < 18 || age > 110) {
            ageEl.focus();
            showToast("Age must be between 18 and 110.", 3000);
            return false;
        }
    }

    if (ardEl && ardEl.value !== "") {
        if (!isArdValid(ardEl.value)) {
            ardEl.dataset.invalid = "true";
            ardEl.focus();
            showToast("ARD must be within the last year and not after today.", 3000);
            updateGenerateButtonState();
            return false;
        }
        ardEl.dataset.invalid = "false";
    }

    updateGenerateButtonState();
    return true;
}

function sanitizeTextInput(s) {
    if (!s) return '';
    // Trim and remove control characters that could be abused in downstream systems
    return String(s).trim().replace(/[\x00-\x1F\x7F]/g, '');
}

// Validate a name-like field with a conservative whitelist.
// Allows Unicode letters, combining marks, spaces and common name punctuation.
function validName(s) {
    if (!s) return false;
    var v = String(s);
    if (v.normalize) v = v.normalize('NFC');
    v = v.trim();
    try {
        // Use Unicode-aware regex when supported
        var re = new RegExp("^[\\p{L}\\p{M} .,'-]{1,30}$","u");
        return re.test(v);
    } catch (e) {
        // Fallback for environments without \p support
        var ascii = /^[A-Za-z .,'-]{1,30}$/;
        return ascii.test(v);
    }
}

function generateNote() {

    if (!validateFormValues()) {
        return;
    }

    var name = sanitizeTextInput(document.getElementById("residentName").value);
    var age = sanitizeTextInput(document.getElementById("age").value);
    var ard = sanitizeTextInput(document.getElementById("ard").value);
    var ardDisplay = "";
    if (ard) {
        // Use local date parsing to avoid timezone shift (so it won't show yesterday)
        var ardDate = parseLocalDate(ard);
        var yy = String(ardDate.getFullYear()).slice(-2); // last two digits
        ardDisplay = (ardDate.getMonth() + 1) + "/" + ardDate.getDate() + "/" + yy;
    }
    var dpoa = sanitizeTextInput(document.getElementById("dpoa").value);
    var noteType = sanitizeTextInput(document.getElementById("noteType").value);

    var orientation = sanitizeTextInput(document.getElementById("orientation").value);
    var bims = sanitizeTextInput(document.getElementById("bims").value);
    var phq = sanitizeTextInput(document.getElementById("phq").value);
    var behavior = sanitizeTextInput(document.getElementById("behavior").value);
    var careConference = sanitizeTextInput(document.getElementById("careConference").value);
    var polst = sanitizeTextInput(document.getElementById("polst").value);

    var note = "";

    note += "MDS " + noteType + " NOTE\n\n";

    note += "ARD:\n";
    note += ardDisplay + "\n\n";

    note += "RESIDENT SUMMARY:\n";
    note += "Resident prefers to be called " + name +
            ". The resident is " + age +
            " years old. The following was collected through observation and interaction with the resident, weekly interdisciplinary team reports, and MDS interviews with the resident and staff.\n\n";

    note += "COGNITION:\n";
    note += orientation + " ";
    note += "SW approached " + name + " to complete the BIMS assessment, " + bims + " ";
    note += "SW will continue to monitor for any changes in cognition and adjust the care plan accordingly.\n\n";

    note += "MOOD:\n";
    note += "SW completed the PHQ-2 to 9 assessment with " + phq + " ";
    note += "Staff and SW will continue to monitor mood and emotional well-being as indicated.\n\n";

    note += "BEHAVIOR:\n";
    note += behavior + " ";
    note += "Staff will continue to monitor for changes in behavior and response to treatment.\n\n";

    note += "INTERVENTIONS:\n";
    note += "KGH staff continue to provide encouragement, assistance, and support to promote resident independence, autonomy, and sense of control whenever possible. Additional interventions are outlined in the person-centered care plan and activity notes.\n\n";

    note += "DISCHARGE:\n";
    note += name + " is appropriate for long-term care placement based on current care needs. ";
    note += "Care conference " + careConference + "\n\n";

    note += "ADVANCE DIRECTIVES:\n";
    note += "No changes to advance directives. ";
    note += "POLST code status is " + polst + ". ";
    note += "DPOA specifies decision maker is " + dpoa + ".";

    var outputEl = document.getElementById("output");
    outputEl.value = note;
    // Auto-resize textarea to fit content
    outputEl.style.height = 'auto';
    outputEl.style.height = outputEl.scrollHeight + 'px';
}


function copyNote() {

    var output = document.getElementById("output");

    if (output.value.trim() === "") {
        showToast("Generate a note first.", 3000);
        return;
    }

    if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(output.value)
            .then(function() {
                showToast("Note copied to clipboard.", 3000);
            })
            .catch(function() {
                fallbackCopy(output);
            });
    } else {
        fallbackCopy(output);
    }
}

function fallbackCopy(output) {
    try {
        output.select();
        document.execCommand("copy");
        showToast("Note copied to clipboard.", 3000);
    } catch (e) {
        showToast("Copy failed. Please copy manually.", 3000);
    }
}

// Keep BIMS consistent with Orientation selection when appropriate
function syncBIMSWithOrientation() {
    var orientationEl = document.getElementById("orientation");
    var bimsEl = document.getElementById("bims");
    if (!orientationEl || !bimsEl) return;

    var orientationDeclined = "Resident declined to participate in BIMS assessment.";
    var bimsDeclinedText = "resident declined to participate in assessment. SW proceeded to staff interviews.";

    // find the declined option in the BIMS select
    var declinedOptionIndex = Array.from(bimsEl.options).findIndex(function(o){ return o.text === bimsDeclinedText; });
    var declinedOption = declinedOptionIndex >= 0 ? bimsEl.options[declinedOptionIndex] : null;

    if (orientationEl.value === orientationDeclined) {
        // when orientation explicitly indicates decline, enable and select only the declined BIMS option
        if (declinedOption) {
            declinedOption.disabled = false;
            bimsEl.selectedIndex = declinedOptionIndex;
        }
        bimsEl.disabled = true; // prevent user changes
    } else {
        // otherwise, make the declined option unselectable and re-enable the control
        if (declinedOption) {
            // disable the declined option so it can't be selected manually
            declinedOption.disabled = true;
            // if it was currently selected, clear selection
            var curr = bimsEl.options[bimsEl.selectedIndex] && bimsEl.options[bimsEl.selectedIndex].text;
            if (curr === bimsDeclinedText) bimsEl.selectedIndex = 0;
        }
        bimsEl.disabled = false;
    }
}

// Toast helper
function showToast(message, duration) {
    duration = duration || 3000;
    var container = document.getElementById('toastContainer');
    if (!container) return;
    // Remove any existing toast so only one shows at a time
    var existing = container.querySelector('.toast');
    if (existing) {
        try { container.removeChild(existing); } catch (e) { /* ignore */ }
    }
    var t = document.createElement('div');
    t.className = 'toast';
    t.textContent = message;
    container.appendChild(t);
    // Auto-dismiss (safely remove only if still attached)
    setTimeout(function() {
        t.classList.add('hide');
        setTimeout(function(){ if (t.parentNode === container) { container.removeChild(t); } }, 350);
    }, duration);
}

function clearForm() {

    document.querySelectorAll("input").forEach(function(el){
        el.value = "";
    });

    document.querySelectorAll("select").forEach(function(el){
        el.selectedIndex = 0;
    });

    var outputEl = document.getElementById("output");
    outputEl.value = "";
    outputEl.style.height = '';
}

document.addEventListener("DOMContentLoaded", function() {

    var gen = document.getElementById("generateBtn");
    if (gen) gen.addEventListener("click", generateNote);

    var copyBtn = document.getElementById("copyBtn");
    if (copyBtn) copyBtn.addEventListener("click", copyNote);

    var clearBtn = document.getElementById("clearBtn");
    if (clearBtn) clearBtn.addEventListener("click", clearForm);

    var printBtn = document.getElementById("printBtn");
    if (printBtn) printBtn.addEventListener("click", function() { window.print(); });

    setDateLimits();

    var ardEl = document.getElementById("ard");
    if (ardEl) {
        ardEl.addEventListener("change", function() {
            setDateLimits();
            validateFormValues();
        });
    }

    var ageEl = document.getElementById("age");
    if (ageEl) {
        ageEl.addEventListener("input", function() { validateFormValues(); });
        ageEl.addEventListener("change", function() { validateFormValues(); });
    }

    updateGenerateButtonState();

    // wire up orientation -> BIMS sync
    var orientationEl = document.getElementById("orientation");
    if (orientationEl) {
        orientationEl.addEventListener("change", syncBIMSWithOrientation);
        // initial sync on load
        syncBIMSWithOrientation();
    }

    // adjust BIMS select to fit longest option
    if (typeof adjustBIMSWidth === 'function') {
        adjustBIMSWidth();
        window.addEventListener('resize', function() { adjustBIMSWidth(); });
    }

});


// Measure longest option text and set the BIMS select width accordingly
function adjustBIMSWidth() {
    var bimsEl = document.getElementById('bims');
    if (!bimsEl) return;
    var options = Array.from(bimsEl.options).map(function(o){ return o.text; });
    if (!options.length) return;
    var longest = options.reduce(function(a,b){ return a.length > b.length ? a : b; });

    var span = document.createElement('span');
    span.style.visibility = 'hidden';
    span.style.position = 'absolute';
    span.style.whiteSpace = 'nowrap';
    var cs = window.getComputedStyle(bimsEl);
    span.style.font = cs.font || (cs.fontSize + ' ' + cs.fontFamily);
    span.textContent = longest;
    document.body.appendChild(span);
    var textWidth = span.getBoundingClientRect().width;
    document.body.removeChild(span);

    // Add extra space for select arrow and padding
    var extra = 56;
    var desired = Math.ceil(textWidth + extra);

    // Cap at container width minus some margin
    var container = document.querySelector('.container');
    var maxWidth = container ? Math.floor(container.getBoundingClientRect().width - 40) : window.innerWidth - 40;
    if (desired > maxWidth) desired = maxWidth;

    bimsEl.style.width = desired + 'px';
}
