describe('MDS HTML basic checks', () => {
  beforeEach(() => {
    cy.visit('/MDS_html.html')
  })

  it('checks field attributes and limits', () => {
    cy.get('#age').invoke('attr', 'min').should('eq', '18')
    cy.get('#age').invoke('attr', 'max').should('eq', '110')
    cy.get('#residentName').invoke('attr', 'maxlength').should('eq', '30')
    cy.get('#dpoa').invoke('attr', 'maxlength').should('eq', '30')

    const today = new Date().toISOString().split('T')[0]
    const minDate = new Date(Date.now() - 365 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]
    cy.get('#ard').invoke('attr', 'min').should('eq', minDate)
    cy.get('#ard').invoke('attr', 'max').should('eq', today)

    // typing over-long names should be truncated to maxlength
    const longName = 'A'.repeat(35)
    cy.get('#residentName').clear().type(longName)
    cy.get('#residentName').invoke('val').then(v => expect(v.length).to.equal(30))

    const longDpoa = 'B'.repeat(35)
    cy.get('#dpoa').clear().type(longDpoa)
    cy.get('#dpoa').invoke('val').then(v => expect(v.length).to.equal(30))
  })

  it('prevents note generation for invalid ages', () => {
    cy.get('#age').clear().type('16')
    cy.get('#noteType').select('Admission')
    cy.get('#generateBtn').click()
    cy.get('#output').invoke('val').should('eq', '')

    cy.get('#age').clear().type('120')
    cy.get('#noteType').select('Admission')
    cy.get('#generateBtn').click()
    cy.get('#output').invoke('val').should('eq', '')
  })

  it('prevents note generation for future ARD', () => {
    const tomorrow = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString().split('T')[0]
    // set the date value directly
    cy.get('#ard').then($el => { $el.val(tomorrow); $el.trigger('input') })
    cy.get('#age').clear().type('82')
    cy.get('#noteType').select('Admission')
    cy.get('#generateBtn').click()
    cy.get('#output').invoke('val').should('eq', '')
  })

  it('generates a note for valid input (happy path)', () => {
    cy.get('#residentName').clear().type('John Doe')
    cy.get('#age').clear().type('82')
    const validArd = new Date(Date.now() - 90 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]
    cy.get('#ard').then($el => { $el.val(validArd); $el.trigger('input') })
    cy.get('#dpoa').clear().type('Jane Smith')
    cy.get('#noteType').select('Admission')
    cy.get('#orientation').select('Resident is alert and oriented x4.')
    cy.get('#bims').select('with a score of 15/15. SW proceeded to PHQ-2 to 9 assessment.')
    cy.get('#phq').select('9/27, indicating mild depression.')
    cy.get('#behavior').select("Resident's behavior is stable. No physical, verbal or other behaviors noted or reported.")
    cy.get('#careConference').select('offered and accepted.')
    cy.get('#polst').select('FULL CODE / FULL TREATMENT')
    cy.get('#generateBtn').click()
    cy.get('#output').invoke('val').should('contain', 'MDS Admission NOTE')
    cy.get('#output').invoke('val').should('contain', 'Resident prefers to be called John Doe')
    cy.get('#output').invoke('val').should('contain', '82 years old')
    cy.get('#output').invoke('val').should('contain', 'DPOA specifies decision maker is Jane Smith')
  })
})
