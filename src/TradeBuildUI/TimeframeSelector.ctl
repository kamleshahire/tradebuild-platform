VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Begin VB.UserControl TimeframeSelector 
   BackStyle       =   0  'Transparent
   ClientHeight    =   1710
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   3705
   ScaleHeight     =   1710
   ScaleWidth      =   3705
   Begin MSComctlLib.ImageCombo TimeframeCombo 
      Height          =   330
      Left            =   360
      TabIndex        =   0
      Top             =   360
      Width           =   3135
      _ExtentX        =   5530
      _ExtentY        =   582
      _Version        =   393216
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      Locked          =   -1  'True
   End
End
Attribute VB_Name = "TimeframeSelector"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

''
' Description here
'
' @remarks
' @see
'
'@/

'@================================================================================
' Interfaces
'@================================================================================

'@================================================================================
' Events
'@================================================================================

Event Change()
Event Click()

'@================================================================================
' Enums
'@================================================================================

'@================================================================================
' Types
'@================================================================================

'@================================================================================
' Constants
'@================================================================================

Private Const ProjectName As String = "TradeBuildUI25"
Private Const ModuleName As String = "TimeframeSelector"

Private Const PropNameBackColor                         As String = "BackColor"
Private Const PropNameForeColor                         As String = "ForeColor"

Private Const PropDfltBackColor                         As Long = vbWindowBackground
Private Const PropDfltForeColor                         As Long = vbWindowText

Private Const TimeframeCustom As String = "Custom"

'@================================================================================
' Member variables
'@================================================================================

Private mTB As tradeBuildAPI
Attribute mTB.VB_VarHelpID = -1

Private mSpecifier As fTimeframeSpecifier

Private mLatestLength As Long
Private mLatestUnit As TimePeriodUnits

'@================================================================================
' Class Event Handlers
'@================================================================================

Private Sub UserControl_InitProperties()
On Error Resume Next

backColor = PropDfltBackColor
foreColor = PropDfltForeColor
End Sub

Private Sub UserControl_ReadProperties(PropBag As PropertyBag)

On Error Resume Next

backColor = PropBag.ReadProperty(PropNameBackColor, PropDfltBackColor)
If Err.Number <> 0 Then
    backColor = PropDfltBackColor
    Err.clear
End If

foreColor = PropBag.ReadProperty(PropNameForeColor, PropDfltForeColor)
If Err.Number <> 0 Then
    backColor = PropDfltForeColor
    Err.clear
End If

End Sub

Private Sub UserControl_Resize()
TimeframeCombo.Left = 0
TimeframeCombo.Top = 0
TimeframeCombo.Width = UserControl.Width
UserControl.Height = TimeframeCombo.Height
End Sub

Private Sub UserControl_WriteProperties(PropBag As PropertyBag)
PropBag.WriteProperty PropNameBackColor, backColor, PropDfltBackColor
PropBag.WriteProperty PropNameForeColor, foreColor, PropDfltForeColor
End Sub

'@================================================================================
' XXXX Interface Members
'@================================================================================

'@================================================================================
' Control Event Handlers
'@================================================================================

Private Sub TimeframeCombo_Change()
RaiseEvent Change
End Sub

Private Sub TimeframeCombo_Click()
Dim tp As TimePeriod
If TimeframeCombo.Text = TimeframeCustom Then
    If mSpecifier Is Nothing Then
        Set mSpecifier = New fTimeframeSpecifier
        mSpecifier.tradeBuildAPI = mTB
    End If
    mSpecifier.Show vbModal
    If Not mSpecifier.cancelled Then
        tp = mSpecifier.timeframeDesignator
        selectComboEntry tp.length, tp.units
        RaiseEvent Click
    Else
        selectComboEntry mLatestLength, mLatestUnit
    End If
Else
    RaiseEvent Click
End If
End Sub

'@================================================================================
' XXXX Event Handlers
'@================================================================================

'@================================================================================
' Properties
'@================================================================================

Public Property Let backColor( _
                ByVal value As OLE_COLOR)
TimeframeCombo.backColor = value
End Property

Public Property Get backColor() As OLE_COLOR
backColor = TimeframeCombo.backColor
End Property

Public Property Let foreColor( _
                ByVal value As OLE_COLOR)
TimeframeCombo.foreColor = value
End Property

Public Property Get foreColor() As OLE_COLOR
foreColor = TimeframeCombo.foreColor
End Property

Public Property Get Text() As String
Attribute Text.VB_UserMemId = 0
Text = TimeframeCombo.Text
End Property

Public Property Let timeframeDesignator( _
                ByRef value As TimePeriod)

If mTB Is Nothing Then
    Err.Raise ErrorCodes.ErrIllegalStateException, _
            ProjectName & "." & ModuleName & ":" & "timeframeDesignator", _
            "No reference to TradeBuildAPI supplied yet"
End If

selectComboEntry value.length, value.units
End Property

Public Property Get timeframeDesignator() As TimePeriod

If mTB Is Nothing Then
    Err.Raise ErrorCodes.ErrIllegalStateException, _
            ProjectName & "." & ModuleName & ":" & "timeframeDesignator", _
            "No reference to TradeBuildAPI supplied yet"
End If

timeframeDesignator = TimePeriodFromString(TimeframeCombo.selectedItem.Text)

End Property

Public Property Let tradeBuildAPI( _
                ByVal tb As tradeBuildAPI)
Set mTB = tb
setupTimeframeCombo
End Property
                
'@================================================================================
' Methods
'@================================================================================

Public Sub selectTimeframe( _
                ByRef tfDesignator As TimePeriod)

If mTB Is Nothing Then
    Err.Raise ErrorCodes.ErrIllegalStateException, _
            ProjectName & "." & ModuleName & ":" & "timeframeDesignator", _
            "No reference to TradeBuildAPI supplied yet"
End If

selectComboEntry tfDesignator.length, tfDesignator.units
End Sub

'@================================================================================
' Helper Functions
'@================================================================================

Private Sub addComboEntry( _
                ByVal periodlength As Long, _
                ByVal periodUnit As TimePeriodUnits)
                
Dim tp As TimePeriod
Dim s As String

tp.length = periodlength
tp.units = periodUnit
s = TimePeriodToString(tp)
If mTB.IsSupportedHistoricalDataPeriod(periodlength, periodUnit) Then
    TimeframeCombo.ComboItems.add , s, s
End If
End Sub

Private Sub insertComboEntry( _
                ByVal periodlength As Long, _
                ByVal periodUnit As TimePeriodUnits)
                
Dim tp As TimePeriod
Dim s As String
Dim i As Long
Dim unitFound As Boolean

tp.length = periodlength
tp.units = periodUnit
s = TimePeriodToString(tp)
If mTB.IsSupportedHistoricalDataPeriod(periodlength, periodUnit) Then
    For i = 2 To TimeframeCombo.ComboItems.count
        Dim currTp As TimePeriod
        currTp = TimePeriodFromString(TimeframeCombo.ComboItems(i).Text)
        If currTp.units = periodUnit Then unitFound = True
        If currTp.units = periodUnit And currTp.length > periodlength Then Exit For
        If unitFound And currTp.units <> periodUnit Then Exit For
    Next
    TimeframeCombo.ComboItems.add i, s, s
    TimeframeCombo.Refresh
End If
End Sub

Private Function selectComboEntry( _
                ByVal periodlength As Long, _
                ByVal periodUnit As TimePeriodUnits) As Boolean
Dim tp As TimePeriod
Dim s As String

On Error GoTo Err

tp.length = periodlength
tp.units = periodUnit
s = TimePeriodToString(tp)
If mTB.IsSupportedHistoricalDataPeriod(periodlength, periodUnit) Then
    TimeframeCombo.ComboItems.item(s).Selected = True
    mLatestLength = periodlength
    mLatestUnit = periodUnit
    selectComboEntry = True
End If

Exit Function

Err:

If Err.Number = 35601 Then
    insertComboEntry periodlength, periodUnit
    Resume
End If

Err.Raise Err.Number
End Function

Private Sub setupTimeframeCombo()
TimeframeCombo.ComboItems.clear
TimeframeCombo.ComboItems.add , TimeframeCustom, TimeframeCustom
addComboEntry 5, TimePeriodSecond
addComboEntry 15, TimePeriodSecond
addComboEntry 30, TimePeriodSecond
addComboEntry 1, TimePeriodMinute
addComboEntry 2, TimePeriodMinute
addComboEntry 3, TimePeriodMinute
addComboEntry 4, TimePeriodMinute
addComboEntry 5, TimePeriodMinute
addComboEntry 8, TimePeriodMinute
addComboEntry 10, TimePeriodMinute
addComboEntry 13, TimePeriodMinute
addComboEntry 15, TimePeriodMinute
addComboEntry 20, TimePeriodMinute
addComboEntry 21, TimePeriodMinute
addComboEntry 30, TimePeriodMinute
addComboEntry 34, TimePeriodMinute
addComboEntry 55, TimePeriodMinute
addComboEntry 1, TimePeriodHour
addComboEntry 1, TimePeriodDay
addComboEntry 1, TimePeriodWeek
addComboEntry 1, TimePeriodMonth
addComboEntry 100, TimePeriodVolume
addComboEntry 1000, TimePeriodVolume
addComboEntry 4, TimePeriodTickMovement
addComboEntry 5, TimePeriodTickMovement
addComboEntry 10, TimePeriodTickMovement
addComboEntry 20, TimePeriodTickMovement

If selectComboEntry(5, TimePeriodMinute) Then
ElseIf selectComboEntry(10, TimePeriodMinute) Then
ElseIf selectComboEntry(15, TimePeriodMinute) Then
ElseIf selectComboEntry(20, TimePeriodMinute) Then
ElseIf selectComboEntry(30, TimePeriodMinute) Then
ElseIf selectComboEntry(1, TimePeriodHour) Then
ElseIf selectComboEntry(1, TimePeriodDay) Then
ElseIf selectComboEntry(1, TimePeriodWeek) Then
Else
    selectComboEntry 1, TimePeriodMonth
End If
End Sub

