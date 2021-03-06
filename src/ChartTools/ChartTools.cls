VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ChartTools"
Attribute VB_GlobalNameSpace = True
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

''
' Description here
'
'@/

'@================================================================================
' Interfaces
'@================================================================================

'@================================================================================
' Events
'@================================================================================

'@================================================================================
' Enums
'@================================================================================

'@================================================================================
' Types
'@================================================================================

'@================================================================================
' Constants
'@================================================================================


Private Const ModuleName                    As String = "ChartTools"

'@================================================================================
' Member variables
'@================================================================================

'@================================================================================
' Class Event Handlers
'@================================================================================

'@================================================================================
' XXXX Interface Members
'@================================================================================

'@================================================================================
' XXXX Event Handlers
'@================================================================================

'@================================================================================
' Properties
'@================================================================================

'@================================================================================
' Methods
'@================================================================================

Public Function CreateFibRetracementTool( _
                ByVal pChart As ChartController, _
                ByRef pLineSpecs() As FibLineSpecifier, _
                Optional ByVal Layer As LayerNumbers = -1, _
                Optional ByVal pTextStyle As TextStyle) As FibRetracementTool
Const ProcName As String = "CreateFibRetracementTool"
On Error GoTo Err

If pChart Is Nothing Or Not TypeOf pChart Is ChartController Then
    Err.Raise ErrorCodes.ErrIllegalArgumentException, _
            ProjectName & "." & ModuleName & ":" & ProcName, _
            "You must supply a Chart"
End If

Set CreateFibRetracementTool = New FibRetracementTool
CreateFibRetracementTool.Initialise pChart, pLineSpecs, Layer, pTextStyle

Exit Function

Err:
gHandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:=ProcName, pModuleName:=ModuleName
End Function

Public Function CreateLineTool( _
                ByVal pChart As ChartController, _
                Optional ByVal pLineStyle As LineStyle, _
                Optional ByVal Layer As LayerNumbers = -1) As LineTool
Const ProcName As String = "CreateLineTool"
On Error GoTo Err

If pChart Is Nothing Or Not TypeOf pChart Is ChartController Then
    Err.Raise ErrorCodes.ErrIllegalArgumentException, _
            ProjectName & "." & ModuleName & ":" & ProcName, _
            "You must supply a Chart"
End If

Set CreateLineTool = New LineTool
CreateLineTool.Initialise pChart, pLineStyle, Layer

Exit Function

Err:
gHandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:=ProcName, pModuleName:=ModuleName
End Function

'@================================================================================
' Helper Functions
'@================================================================================


