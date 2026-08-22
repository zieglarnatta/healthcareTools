describe('Pairwise generated cases', () => {
  before(() => {
    // ensure the fixture exists; if not, tests will skip
  })

  it('runs generated pairwise cases from fixture', () => {
    cy.readFile('cypress/fixtures/pairwise_cases.json').then(cases => {
      if (!cases || !cases.length) {
        cy.log('No generated cases found; skipping')
        return
      }

      cases.forEach(tc => {
        cy.log('Case: ' + tc.name)
        cy.visit('/MDS_html.html')
        cy.get('#residentName').clear().type(tc.residentName)
        cy.get('#dpoa').clear().type(tc.dpoa)
        if (tc.age) cy.get('#age').clear().type(tc.age)
        if (tc.ard) cy.get('#ard').then($el => { $el.val(tc.ard); $el.trigger('input') })
        if (tc.orientation) cy.get('#orientation').select(tc.orientation)
        if (tc.bims) cy.get('#bims').select(tc.bims)
        if (tc.phq) cy.get('#phq').select(tc.phq)
        if (tc.behavior) cy.get('#behavior').select(tc.behavior)
        if (tc.careConference) cy.get('#careConference').select(tc.careConference)
        if (tc.polst) cy.get('#polst').select(tc.polst)
        if (tc.noteType) cy.get('#noteType').select(tc.noteType)
        cy.get('#generateBtn').click()
        cy.get('#output').invoke('val').should('contain', tc.residentName)
      })
    })
  })
})
