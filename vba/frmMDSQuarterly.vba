Private Sub UserForm_Initialize()
    With cmbPHQ
        .Clear
        .AddItem ""
        .AddItem "score of 9/27, indicating mild depression."
        .AddItem "score of 10/27, indicating moderate depression."
        .AddItem "score of 11/27, indicating moderate depression."
        .AddItem "score of 12/27, indicating moderate depression."
        .AddItem "score of 13/27, indicating moderate depression."
        .AddItem "score of 14/27, indicating moderate depression."
        .AddItem "score of 15/27, indicating moderately severe depression."
        .AddItem "score of 16/27, indicating moderately severe depression."
        .AddItem "score of 17/27, indicating moderately severe depression."
        .AddItem "score of 18/27, indicating moderately severe depression."
        .AddItem "score of 19/27, indicating moderately severe depression."
        .AddItem "score of 20/27, indicating severe depression."
        .AddItem "score of 21/27, indicating severe depression."
        .AddItem "score of 22/27, indicating severe depression."
        .AddItem "score of 23/27, indicating severe depression."
        .AddItem "score of 24/27, indicating severe depression."
        .AddItem "score of 25/27, indicating severe depression."
        .AddItem "score of 26/27, indicating severe depression."
        .AddItem "score of 27/27, indicating severe depression."
        .ListIndex = 0
    End With

    With cmbOrientation
        .Clear
        .AddItem ""
        .AddItem "Resident is alert and oriented x4."
        .AddItem "Resident is alert and oriented x3."
        .AddItem "Resident is alert and oriented x2."
        .AddItem "Resident is alert and oriented x1."
        .AddItem "Resident declined to participate in BIMS assessment."
        .ListIndex = 0
    End With

    With cmbBehavior
        .Clear
        .AddItem ""
        .AddItem "Resident's behavior is stable. No physical, verbal or other behaviors noted or reported."
        .AddItem "Resident's behavior is not stable."
        .AddItem "Resident's behavior is stable."
        .AddItem "Occasional verbal agitation noted."
        .AddItem "Requires staff redirection at times."
        .AddItem "No significant behavior concerns."
        .ListIndex = 0
    End With

    With cmbCareConference
        .Clear
        .AddItem ""
        .AddItem "offered and accepted."
        .AddItem "offered and declined."
        .AddItem "held with family present."
        .AddItem "not conducted this quarter."
        .ListIndex = 0
    End With

    With cmbPOLST
        .Clear
        .AddItem ""
        .AddItem "FULL CODE / FULL TREATMENT"
        .AddItem "FULL CODE / SELECTIVE TREATMENT"
        .AddItem "DNR / FULL TREATMENT"
        .AddItem "DNR / SELECTIVE TREATMENT"
        .AddItem "DNR / COMFORT-FOCUSED TREATMENT"
        .ListIndex = 0
    End With
End Sub

Private Sub cmdGenerate_Click()
    Dim NoteText As String
    Dim N As String

    N = txtResidentName.Value
    NoteText = ""

    NoteText = NoteText & "MDS QUARTERLY NOTE" & vbCrLf & vbCrLf

    NoteText = NoteText & "ARD:" & vbCrLf & _
        txtARD.Value & vbCrLf & vbCrLf

    NoteText = NoteText & "RESIDENT SUMMARY:" & vbCrLf & _
        "Resident prefers to be called " & N & _
        ". The resident is " & txtAge.Value & _
        " years old. The following was collected through observation and interaction with the resident, " & _
        "weekly interdisciplinary team reports, and MDS interviews with the resident and staff." & vbCrLf & vbCrLf

    NoteText = NoteText & "COGNITION:" & vbCrLf & _
        cmbOrientation.Value & " " & _
        "SW will continue to monitor for any changes in cognition and adjust the care plan accordingly." & vbCrLf & vbCrLf

    NoteText = NoteText & "MOOD:" & vbCrLf & _
        "SW completed the PHQ-2 to 9 assessment with " & cmbPHQ.Value & " " & _
        "Staff and SW will continue to monitor mood and emotional well-being as indicated." & vbCrLf & vbCrLf

    NoteText = NoteText & "BEHAVIOR:" & vbCrLf & _
        cmbBehavior.Value & " " & _
        "Staff will continue to monitor for changes in behavior and response to treatment." & vbCrLf & vbCrLf

    NoteText = NoteText & "INTERVENTIONS:" & vbCrLf & _
        "KGH staff continue to provide encouragement, assistance, and support to promote resident independence, autonomy, and sense of control whenever possible. " & _
        "Additional interventions are outlined in the person-centered care plan and activity notes." & vbCrLf & vbCrLf

    NoteText = NoteText & "DISCHARGE:" & vbCrLf & _
        cmbDischarge.Value & vbCrLf & _
        "Care conference " & cmbCareConference.Value & vbCrLf & vbCrLf

    NoteText = NoteText & "ADVANCE DIRECTIVES:" & vbCrLf & _
        "No changes to advance directives. " & _
        "POLST code status is " & cmbPOLST.Value & ". " & _
        "DPOA specifies decision maker is " & txtDPOA.Value & "."

    Selection.TypeText Text:=NoteText
    Unload Me
End Sub
