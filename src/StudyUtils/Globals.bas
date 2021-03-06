Attribute VB_Name = "Globals"
Option Explicit

'@================================================================================
' Description
'@================================================================================
'
'

'@================================================================================
' Interfaces
'@================================================================================

'@================================================================================
' Events
'@================================================================================

'@================================================================================
' Constants
'@================================================================================

Public Const ProjectName                        As String = "StudyUtils27"

Public Const AskInputName                       As String = "Ask"
Public Const BidInputName                       As String = "Bid"
Public Const OpenInterestInputName              As String = "Open interest"
Public Const TickVolumeInputName                As String = "Tick Volume"
Public Const TradeInputName                     As String = "Trade"
Public Const VolumeInputName                    As String = "Total Volume"
Public Const ValueInputName                     As String = "Value"
Public Const BarNumberInputName                 As String = "Bar number"

Public Const AttributeNameEnabled               As String = "Enabled"
Public Const AttributeNameStudyLibraryBuiltIn   As String = "BuiltIn"
Public Const AttributeNameStudyLibraryProgId    As String = "ProgId"

Public Const BuiltInStudyLibProgId              As String = "CmnStudiesLib27.StudyLib"
Public Const BuiltInStudyLibName                As String = "BuiltIn"

Public Const ConfigNameStudyLibraries           As String = "StudyLibraries"
Public Const ConfigNameStudyLibrary             As String = "StudyLibrary"

Public Const ConstTickVolumeBarsStudyName       As String = "Constant Tick Volume bars"
Public Const ConstTickVolumeBarsStudyShortName  As String = "CTV Bars"
Public Const ConstTickVolumeBarsParamTicksPerBar As String = "Ticks per bar"

Public Const ConstTimeBarsStudyName             As String = "Constant Time Bars"
Public Const ConstTimeBarsStudyShortName        As String = "Bars"
Public Const ConstTimeBarsParamBarLength        As String = "Bar length"
Public Const ConstTimeBarsParamTimeUnits        As String = "Time units"

Public Const ConstVolumeBarsStudyName           As String = "Constant Volume bars"
Public Const ConstVolumeBarsStudyShortName      As String = "CV Bars"
Public Const ConstVolumeBarsParamVolPerBar      As String = "Volume per bar"

Public Const ConstMomentumBarsStudyName         As String = "Constant Momentum Bars"
Public Const ConstMomentumBarsStudyShortName    As String = "CM Bars"
Public Const ConstMomentumBarsParamTicksPerBar  As String = "Ticks move per bar"

Public Const UserDefinedBarsStudyName           As String = "User-defined Bars"
Public Const UserDefinedBarsStudyShortName      As String = "UD Bars"

Public Const DefaultStudyValueNameStr           As String = "$DEFAULT"
Public Const MovingAverageStudyValueNameStr     As String = "MA"

' sub-Value names for study values in bar mode
Public Const BarStudyValueBar                   As String = "Bar"
Public Const BarStudyValueOpen                  As String = "Open"
Public Const BarStudyValueHigh                  As String = "High"
Public Const BarStudyValueLow                   As String = "Low"
Public Const BarStudyValueClose                 As String = "Close"
Public Const BarStudyValueVolume                As String = "Volume"
Public Const BarStudyValueTickVolume            As String = "Tick Volume"
Public Const BarStudyValueOpenInterest          As String = "Open Interest"
Public Const BarStudyValueHL2                   As String = "(H+L)/2"
Public Const BarStudyValueHLC3                  As String = "(H+L+C)/3"
Public Const BarStudyValueOHLC4                 As String = "(O+H+L+C)/4"

Public Const StudyLibrariesRenderer             As String = "StudiesUI27.StudyLibConfigurer"


'@================================================================================
' Enums
'@================================================================================

'@================================================================================
' Types
'@================================================================================

'@================================================================================
' External function declarations
'@================================================================================

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

Public Property Get gErrorLogger() As Logger
Static lLogger As Logger
If lLogger Is Nothing Then Set lLogger = GetLogger("error")
Set gErrorLogger = lLogger
End Property

Public Property Get gLogger() As FormattingLogger
Static sLogger As FormattingLogger
If sLogger Is Nothing Then Set sLogger = CreateFormattingLogger("studyutils", ProjectName)
Set gLogger = sLogger
End Property

'@================================================================================
' Methods
'@================================================================================

Public Sub gHandleUnexpectedError( _
                ByRef pProcedureName As String, _
                ByRef pModuleName As String, _
                Optional ByRef pFailpoint As String, _
                Optional ByVal pReRaise As Boolean = True, _
                Optional ByVal pLog As Boolean = False, _
                Optional ByVal pErrorNumber As Long, _
                Optional ByRef pErrorDesc As String, _
                Optional ByRef pErrorSource As String)
Dim errSource As String: errSource = IIf(pErrorSource <> "", pErrorSource, Err.Source)
Dim errDesc As String: errDesc = IIf(pErrorDesc <> "", pErrorDesc, Err.Description)
Dim errNum As Long: errNum = IIf(pErrorNumber <> 0, pErrorNumber, Err.Number)

HandleUnexpectedError pProcedureName, ProjectName, pModuleName, pFailpoint, pReRaise, pLog, errNum, errDesc, errSource
End Sub

Public Sub gNotifyUnhandledError( _
                ByRef pProcedureName As String, _
                ByRef pModuleName As String, _
                Optional ByRef pFailpoint As String, _
                Optional ByVal pErrorNumber As Long, _
                Optional ByRef pErrorDesc As String, _
                Optional ByRef pErrorSource As String)
Dim errSource As String: errSource = IIf(pErrorSource <> "", pErrorSource, Err.Source)
Dim errDesc As String: errDesc = IIf(pErrorDesc <> "", pErrorDesc, Err.Description)
Dim errNum As Long: errNum = IIf(pErrorNumber <> 0, pErrorNumber, Err.Number)

UnhandledErrorHandler.Notify pProcedureName, pModuleName, ProjectName, pFailpoint, errNum, errDesc, errSource
End Sub

Public Sub gSetVariant(ByRef pTarget As Variant, ByRef pSource As Variant)
If IsObject(pSource) Then
    Set pTarget = pSource
Else
    pTarget = pSource
End If
End Sub

'@================================================================================
' Helper Functions
'@================================================================================



