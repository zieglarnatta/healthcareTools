const fs = require('fs')
const path = require('path')

const generatedDir = path.join(__dirname, '..', '..', 'robotFrameworkTests', 'tests', 'generated')
const outDir = path.join(__dirname, '..', 'cypress', 'fixtures')
const outFile = path.join(outDir, 'pairwise_cases.json')

function parseVariables(content) {
  const vars = {}
  const varSectionMatch = content.match(/\*\*\* Variables \*\*\*[\s\S]*?(?=\*\*\* Test Cases \*\*\*)/)
  if (!varSectionMatch) return vars
  const lines = varSectionMatch[0].split(/\r?\n/)
  for (const line of lines) {
    const m = line.match(/^\s*\$\{([^}]+)\}\s+(.*)$/)
    if (m) {
      const name = m[1]
      const val = m[2].trim()
      vars[name] = val
    }
  }
  return vars
}

if (!fs.existsSync(generatedDir)) {
  console.error('Generated directory not found:', generatedDir)
  process.exit(1)
}

const files = fs.readdirSync(generatedDir).filter(f => f.endsWith('.robot')).sort()
const cases = []
for (const f of files) {
  const p = path.join(generatedDir, f)
  const content = fs.readFileSync(p, 'utf8')
  const vars = parseVariables(content)
  // map to a simpler object
  const c = {
    name: f.replace('.robot', ''),
    browser: vars.BROWSER || '',
    noteType: vars.NOTE_TYPE || '',
    residentName: vars.RESIDENT_NAME || '',
    dpoa: vars.DPOA || '',
    age: vars.AGE || '',
    ard: vars.ARD || '',
    orientation: vars.ORIENTATION || '',
    bims: vars.BIMS || '',
    phq: vars.PHQ || '',
    behavior: vars.BEHAVIOR || '',
    careConference: vars.CARE_CONFERENCE || '',
    polst: vars.POLST || ''
  }
  cases.push(c)
}

if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true })
fs.writeFileSync(outFile, JSON.stringify(cases, null, 2), 'utf8')
console.log('Wrote', outFile, 'with', cases.length, 'cases')
