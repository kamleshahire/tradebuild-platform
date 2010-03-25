VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "StreamBasedProcessor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
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

Private Const ProjectName                   As String = "gbd"
Private Const ModuleName                    As String = "StreamBasedProcessor"

'@================================================================================
' Member variables
'@================================================================================

Private mSelfRef As FileBasedProcessor

Private WithEvents mTimeframe As Timeframe
Attribute mTimeframe.VB_VarHelpID = -1

'@================================================================================
' Class Event Handlers
'@================================================================================

'@================================================================================
' mTimeframe Event Handlers
'@================================================================================

Private Sub mTimeframe_BarsLoaded()
gProcessor.Finish
Set gProcessor = Nothing
gCon.writeLineToConsole "Completed"
Set mSelfRef = Nothing
End Sub

'@================================================================================
' Properties
'@================================================================================

'@================================================================================
' Methods
'@================================================================================

Friend Sub startData( _
                ByVal spec As ContractSpecifier, _
                ByVal fromDate As Date, _
                ByVal toDate As Date, _
                ByVal number As Long, _
                ByVal barLength As Long, _
                ByVal barUnits As TimePeriodUnits, _
                ByVal sessionOnly As Boolean)
                
Dim lTicker As Ticker

Set mSelfRef = Me

Set lTicker = TradeBuildAPI.Tickers.Add(TickerOptions.TickerOptUseExchangeTimeZone)
lTicker.LoadTicker spec
gProcessor.Ticker = lTicker

Set mTimeframe = lTicker.Timeframes.AddHistorical(GetTimePeriod(barLength, barUnits), _
                                        "", _
                                        IIf(number = -1, &H7FFFFFFF, number), _
                                        fromDate, _
                                        toDate, _
                                        Not sessionOnly)
gProcessor.Timeframe = mTimeframe
End Sub

'@================================================================================
' Helper Functions
'@================================================================================
