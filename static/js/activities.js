// script.js - behavior for the MDS text generator

// Utility to format Date to YYYY-MM-DD
function toYYYYMMDD(d){
  const mm = String(d.getMonth()+1).padStart(2,'0');
  const dd = String(d.getDate()).padStart(2,'0');
  return `${d.getFullYear()}-${mm}-${dd}`;
}

function addMonths(date, months){
  const d = new Date(date);
  const day = d.getDate();
  d.setMonth(d.getMonth() + months);

  // handle month overflow (e.g., Jan 31 + 1 month -> Feb (not 31))
  if (d.getDate() !== day) {
    d.setDate(0); // go to last day of previous month
  }
  return d;
}

document.addEventListener('DOMContentLoaded', () => {
  const ard = document.getElementById('ard');
  const generateBtn = document.getElementById('generateBtn');
  const clearBtn = document.getElementById('clearBtn');
  const copyBtn = document.getElementById('copyBtn');
  const printBtn = document.getElementById('printBtn');
  const output = document.getElementById('output');
  const rawOutput = document.getElementById('rawOutput');

  // Set date min = 1 month back, max = 6 months forward
  const today = new Date();
  const minDate = addMonths(today, -3);
  const maxDate = addMonths(today, 6);
  ard.min = toYYYYMMDD(minDate);
  ard.max = toYYYYMMDD(maxDate);
  ard.value = toYYYYMMDD(today);

  function validateFormValues(){
    const ageEl = document.getElementById('age');
    if (ageEl && ageEl.value !== '') {
      const age = Number(ageEl.value);
      if (age < 18 || age > 110) {
        ageEl.focus();
        showToast('Age must be between 18 and 110.', 3000);
        return false;
      }
    }

    return true;
  }

  function collectInputs(){
    const data = {
      noteType: document.getElementById('noteType').value,
      ard: document.getElementById('ard').value,
      name: document.getElementById('residentName').value.trim(),
      age: document.getElementById('age').value,
      cognition: document.getElementById('cognition').value,
      communication: document.getElementById('communication').value,
      limited: document.getElementById('limited').value,
      misc: document.getElementById('misc').value
    };
    return data;
  }

  function prettyRaw(data){
    return [
      `Note type: ${data.noteType || '(empty)'}`,
      `ARD: ${data.ard || '(empty)'}`,
      `Name: ${data.name || '(empty)'}`,
      `Age: ${data.age || '(empty)'}`,
      `Cognition: ${data.cognition || '(empty)'}`,
      `Communication: ${data.communication || '(empty)'}`,
      `Limited: ${data.limited || '(empty)'}`,
      `Misc: ${data.misc || '(empty)'}`
    ].join('\n');
  }

  function showToast(message, duration = 3000) {
    const container = document.getElementById('toastContainer');
    if (!container) return;

    const existing = container.querySelector('.toast');
    if (existing) {
      try {
        container.removeChild(existing);
      } catch (e) {
        // ignore
      }
    }

    const toast = document.createElement('div');
    toast.className = 'toast';
    toast.textContent = message;
    container.appendChild(toast);

    setTimeout(() => {
      toast.classList.add('hide');
      setTimeout(() => {
        if (toast.parentNode === container) {
          container.removeChild(toast);
        }
      }, 350);
    }, duration);
  }

  if (printBtn) {
    printBtn.addEventListener('click', function() { window.print(); });
  }

  generateBtn.addEventListener('click', () => {
    if (!validateFormValues()) {
      return;
    }

    const data = collectInputs();
    const dump = prettyRaw(data);
    output.textContent = dump;
    rawOutput.textContent = dump;
  });

  clearBtn.addEventListener('click', () => {
    document.getElementById('noteType').selectedIndex = 0;
    ard.value = toYYYYMMDD(new Date());
    document.getElementById('residentName').value = '';
    document.getElementById('age').value = '';
    document.getElementById('cognition').selectedIndex = 0;
    document.getElementById('communication').selectedIndex = 0;
    document.getElementById('limited').selectedIndex = 0;
    document.getElementById('misc').selectedIndex = 0;
    output.textContent = '';
    rawOutput.textContent = '';
  });

  copyBtn.addEventListener('click', async () => {
    const text = output.textContent.trim() || rawOutput.textContent.trim();
    if (!text) {
      showToast('Nothing to copy.', 3000);
      return;
    }

    try {
      await navigator.clipboard.writeText(text);
      copyBtn.textContent = 'Copied ✓';
      showToast('Copied to clipboard.', 3000);
      setTimeout(() => { copyBtn.textContent = 'Copy note'; }, 3000);
    } catch (e) {
      showToast('Copy failed. Please copy manually.', 3000);
    }
  });
});