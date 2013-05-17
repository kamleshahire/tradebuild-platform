VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "IMarketDataSource"
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

Private Const ModuleName                            As String = "IMarketDataSource"

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

Public Property Get Clock() As Clock
End Property

Public Property Get Contract() As IContract
End Property

Public Property Get ContractSpecifier() As IContractSpecifier
End Property

Public Property Get CurrentQuote(ByVal pTickType As TickTypes) As Quote
End Property

Public Property Get CurrentTick(ByVal pTickType As TickTypes) As GenericTick
End Property

Public Property Get Handle() As Long
End Property

Public Property Get IsMarketDataRequested() As Boolean
End Property

Public Property Get IsMarketDepthRequested() As Boolean
End Property

Public Property Get IsTickReplay() As Boolean
End Property

Public Property Get NumberOfMarketDepthRows() As Long
End Property

Public Property Get Options() As MarketDataSourceOptions
End Property

Public Property Get Key() As String
End Property

Public Property Get PriceChange() As PriceChange
End Property

Public Property Get Session() As Session
End Property

Public Property Get State() As MarketDataSourceStates
End Property

Public Property Get Timestamp() As Date
End Property

'@================================================================================
' Methods
'@================================================================================

Public Sub AddErrorListener(ByVal pListener As ErrorListener)
End Sub

Public Sub AddGenericTickListener(ByVal pListener As IGenericTickListener)
End Sub

Public Sub AddMarketDepthListener(ByVal pListener As IMarketDepthListener)
End Sub

Public Sub AddPriceChangeListener(ByVal pListener As IPriceChangeListener)
End Sub

Public Sub AddQuoteListener(ByVal pListener As IQuoteListener)
End Sub

Public Sub AddRawMarketDepthListener(ByVal pListener As IRawMarketDepthListener)
End Sub

Public Sub AddStateChangeListener(ByVal pListener As StateChangeListener)
End Sub

Public Function ConvertTickToQuote(ByRef pTick As GenericTick) As Quote
End Function

Public Sub Finish()
End Sub

Public Sub NotifyCurrentDOM(ByVal pListener As IMarketDepthListener)
End Sub

Public Sub NotifyCurrentMarketDataQuoteValues(ByVal pListener As IQuoteListener)
End Sub

Public Sub NotifyCurrentMarketDataTickValues(ByVal pListener As IGenericTickListener)
End Sub

Public Sub NotifyCurrentMarketDepthValues(ByVal pListener As IRawMarketDepthListener)
End Sub

Public Sub Refresh()
End Sub

Public Sub RefreshPriceChange(ByVal pListener As IPriceChangeListener)
End Sub

Public Sub RefreshQuotes(ByVal pListener As IQuoteListener)
End Sub

Public Sub RefreshTicks(ByVal pListener As IGenericTickListener)
End Sub

Public Sub RemoveErrorListener(ByVal pListener As ErrorListener)
End Sub

Public Sub RemoveGenericTickListener(ByVal pListener As IGenericTickListener)
End Sub

Public Sub RemoveMarketDepthListener(ByVal pListener As IMarketDepthListener)
End Sub

Public Sub RemovePriceChangeListener(ByVal pListener As IPriceChangeListener)
End Sub

Public Sub RemoveQuoteListener(ByVal pListener As IQuoteListener)
End Sub

Public Sub RemoveRawMarketDepthListener(ByVal pListener As IRawMarketDepthListener)
End Sub

Public Sub RemoveStateChangeListener(ByVal pListener As StateChangeListener)
End Sub

Public Sub StartMarketData()
End Sub

Public Sub StartMarketDepth()
End Sub

Public Sub StopMarketData()
End Sub

Public Sub StopMarketDepth()
End Sub

'@================================================================================
' Helper Functions
'@================================================================================




