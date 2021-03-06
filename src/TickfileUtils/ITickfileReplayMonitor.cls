VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ITickfileReplayMonitor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
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

Private Const ModuleName                            As String = "ITickfileReplayMonitor"

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

Public Sub NotifyEvent( _
                ByRef ev As NotificationEventData)
End Sub

Public Sub NotifyReady( _
                ByVal pSource As Object, _
                ByVal pTickfileSpec As ITickfileSpecifier, _
                Optional ByVal pContractSpec As IContractSpecifier)
End Sub

Public Sub NotifyReplayComplete( _
                ByVal pSource As Object, _
                ByVal pEventsPlayed As Long)
End Sub

Public Sub NotifyTickfilePrepared( _
                ByVal pSource As Object, _
                ByVal pTickfileSpec As ITickfileSpecifier)
End Sub

'@================================================================================
' Helper Functions
'@================================================================================




