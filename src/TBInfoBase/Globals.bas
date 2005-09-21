Attribute VB_Name = "Globals"
Option Explicit

'================================================================================
' Constants
'================================================================================

Public Const NegativeTicks As Byte = &H80
Public Const NoTimestamp As Byte = &H40

Public Const OneMicrosecond As Double = 1# / 86400000000#
Public Const OneMinute As Double = 1# / 1440#

Public Const OperationBits As Byte = &H60
Public Const OperationShifter As Byte = &H20
Public Const PositionBits As Byte = &H1F
Public Const SideBits As Byte = &H80
Public Const SideShifter As Byte = &H80
Public Const SizeTypeBits As Byte = &H30
Public Const SizeTypeShifter As Byte = &H10
Public Const TickTypeBits As Byte = &HF

Public Const TickfileFormatTradeBuildSQL As String = "urn:tradewright.com:names.tickfileformats.TradeBuildSQL"

Public Const ContractInfoSPName As String = "TradeBuild Contract Info Service Provider"
Public Const HistoricDataSPName As String = "TradeBuild Historic Data Service Provider"
Public Const SQLDBTickfileSPName As String = "TradeBuild SQLDB Tickfile Service Provider"

'================================================================================
' Enums
'================================================================================

Public Enum SizeTypes
    ShortSize = 1
    IntSize
    LongSize
End Enum

Public Enum TickTypes
    Bid
    Ask
    ClosePrice
    HighPrice
    LowPrice
    marketDepth
    MarketDepthReset
    Trade
    Volume
    OpenInterest
End Enum

'================================================================================
' Procedures
'================================================================================

Public Function gHistDataCapabilities() As Long
gHistDataCapabilities = _
            HistoricDataServiceProviderCapabilities.HistDataStore
End Function

Public Function gHistDataSupports(ByVal capabilities As Long) As Boolean
gHistDataSupports = (gHistDataCapabilities And capabilities)
End Function

Public Function gSQLDBCapabilities() As Long
gSQLDBCapabilities = _
            TickfileServiceProviderCapabilities.Record Or _
            TickfileServiceProviderCapabilities.RecordMarketDepth Or _
            TickfileServiceProviderCapabilities.Replay Or _
            TickfileServiceProviderCapabilities.ReplayMarketDepth Or _
            TickfileServiceProviderCapabilities.PositionExact Or _
            TickfileServiceProviderCapabilities.SaveContractInformation
End Function

Public Function gSQLDBSupports(ByVal capabilities As Long) As Boolean
gSQLDBSupports = (gSQLDBCapabilities And capabilities)
End Function


Public Function secTypeFromString(ByVal value As String) As SecurityTypes
Select Case UCase$(value)
Case "STK"
    secTypeFromString = SecTypeStock
Case "FUT"
    secTypeFromString = SecTypeFuture
Case "OPT"
    secTypeFromString = SecTypeOption
Case "FOP"
    secTypeFromString = SecTypeFuturesOption
Case "CASH"
    secTypeFromString = SecTypeCash
Case "IND"
    secTypeFromString = SecTypeIndex
End Select
End Function

Public Function secTypeToString(ByVal value As SecurityTypes) As String
Select Case value
Case SecTypeStock
    secTypeToString = "STK"
Case SecTypeFuture
    secTypeToString = "FUT"
Case SecTypeOption
    secTypeToString = "OPT"
Case SecTypeFuturesOption
    secTypeToString = "FOP"
Case SecTypeCash
    secTypeToString = "CASH"
Case SecTypeIndex
    secTypeToString = "IND"
End Select
End Function

Public Function gTruncateTimeToNextMinute(ByVal timestamp As Date) As Date
gTruncateTimeToNextMinute = Int((timestamp + OneMinute - OneMicrosecond) / OneMinute) * OneMinute
End Function

Public Function gTruncateTimeToMinute(ByVal timestamp As Date) As Date
gTruncateTimeToMinute = Int((timestamp + OneMicrosecond) / OneMinute) * OneMinute
End Function
