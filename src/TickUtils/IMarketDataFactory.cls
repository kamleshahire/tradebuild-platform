VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "IMarketDataFactory"
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

Private Const ModuleName                            As String = "IMarketDataFactory"

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

Public Property Get MaxStreamId() As Long
End Property

'@================================================================================
' Methods
'@================================================================================

Public Sub CancelMarketData(ByVal pStreamId As Long)
End Sub

Public Sub CancelMarketDepth(ByVal pStreamId As Long)
End Sub

Public Sub RequestMarketData(ByVal pStreamId As Long, ByVal pContract As IContract, ByVal pDataListener As IGenericTickListener, ByVal pErrorListener As IMarketDataErrorListener)
End Sub

Public Sub RequestMarketDepth(ByVal pStreamId As Long, ByVal pContract As IContract, ByVal pNumberOfRows As Long, ByVal pDataListener As IGenericTickListener, ByVal pErrorListener As IMarketDataErrorListener)
End Sub

'@================================================================================
' Helper Functions
'@================================================================================



