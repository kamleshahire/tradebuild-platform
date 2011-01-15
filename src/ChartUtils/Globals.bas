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

Public Const ProjectName                    As String = "ChartUtils26"
Private Const ModuleName                    As String = "Globals"

Private Const ConfigSectionDefaultStudyConfig   As String = "DefaultStudyConfig"

Public Const MinDouble                      As Double = -(2 - 2 ^ -52) * 2 ^ 1023
Public Const MaxDouble                      As Double = (2 - 2 ^ -52) * 2 ^ 1023

Public Const OneMicroSecond                 As Double = 1.15740740740741E-11

Public Const RegionNameCustom               As String = "$custom"
Public Const RegionNameDefault              As String = "$default"
Public Const RegionNameUnderlying           As String = "$underlying"
Public Const RegionNamePrice                As String = "Price"
Public Const RegionNameVolume               As String = "Volume"

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

Private mDefaultStudyConfigurations         As Collection

Private mConfig                             As ConfigurationSection

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

Public Property Get gChartStylesManager() As ChartStylesManager
Const ProcName As String = "gChartStylesManager"
On Error GoTo Err

Static lChartStylesManager As ChartStylesManager

If lChartStylesManager Is Nothing Then Set lChartStylesManager = New ChartStylesManager
Set gChartStylesManager = lChartStylesManager

Exit Property

Err:
gHandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:=ProcName, pModuleName:=ModuleName
End Property

Public Property Get gLogger() As Logger
Static lLogger As Logger
If lLogger Is Nothing Then Set lLogger = GetLogger("log")
Set gLogger = lLogger
End Property

'@================================================================================
' Methods
'@================================================================================

Public Function gGetDefaultStudyConfiguration( _
                ByVal Name As String, _
                ByVal studyLibName As String) As StudyConfiguration
Dim studyConfig As StudyConfiguration
Const ProcName As String = "gGetDefaultStudyConfiguration"
Dim failpoint As String
On Error GoTo Err

If mDefaultStudyConfigurations Is Nothing Then
    Set mDefaultStudyConfigurations = New Collection
End If
On Error Resume Next
Set studyConfig = mDefaultStudyConfigurations.Item(calcDefaultStudyKey(Name, studyLibName))
On Error GoTo Err

If Not studyConfig Is Nothing Then
    Set gGetDefaultStudyConfiguration = studyConfig.Clone
Else
    'no default Study config currently exists so we'll create one from the Study definition
    Dim sd As StudyDefinition
    Set sd = GetStudyDefinition(Name, studyLibName)

    Set studyConfig = New StudyConfiguration
    studyConfig.Name = Name
    studyConfig.StudyLibraryName = studyLibName

    Select Case sd.DefaultRegion
        Case StudyDefaultRegions.StudyDefaultRegionNone
            studyConfig.ChartRegionName = RegionNameUnderlying
        Case StudyDefaultRegions.StudyDefaultRegionCustom
            studyConfig.ChartRegionName = RegionNameCustom
        Case StudyDefaultRegions.StudyDefaultRegionUnderlying
            studyConfig.ChartRegionName = RegionNameUnderlying
        Case Else
            studyConfig.ChartRegionName = RegionNameUnderlying
    End Select

    studyConfig.Parameters = GetStudyDefaultParameters(Name, studyLibName)
    
    Dim InputValueNames() As String
    ReDim InputValueNames(sd.StudyInputDefinitions.count - 1) As String
    
    InputValueNames(0) = DefaultStudyValueName
    If sd.StudyInputDefinitions.count > 1 Then
        Dim i As Long
        For i = 2 To sd.StudyInputDefinitions.count
            InputValueNames(i - 1) = sd.StudyInputDefinitions.Item(i).Name
        Next
    End If
    studyConfig.InputValueNames = InputValueNames

    Dim studyValueDef As StudyValueDefinition
    Dim studyValueConfig As StudyValueConfiguration
    
    For Each studyValueDef In sd.StudyValueDefinitions
        Set studyValueConfig = studyConfig.StudyValueConfigurations.Add(studyValueDef.Name)

        studyValueConfig.IncludeInChart = studyValueDef.IncludeInChart
        Select Case studyValueDef.ValueMode
            Case StudyValueModes.ValueModeNone
                studyValueConfig.DataPointStyle = studyValueDef.ValueStyle
                
            Case StudyValueModes.ValueModeLine
                studyValueConfig.LineStyle = studyValueDef.ValueStyle

            Case StudyValueModes.ValueModeBar
                studyValueConfig.BarStyle = studyValueDef.ValueStyle

            Case StudyValueModes.ValueModeText
                studyValueConfig.TextStyle = studyValueDef.ValueStyle

        End Select

        Select Case studyValueDef.DefaultRegion
            Case StudyValueDefaultRegions.StudyValueDefaultRegionNone
                studyValueConfig.ChartRegionName = RegionNameDefault
            Case StudyValueDefaultRegions.StudyValueDefaultRegionCustom
                studyValueConfig.ChartRegionName = RegionNameCustom
            Case StudyValueDefaultRegions.StudyValueDefaultRegionDefault
                studyValueConfig.ChartRegionName = RegionNameDefault
            Case StudyValueDefaultRegions.StudyValueDefaultRegionUnderlying
                studyValueConfig.ChartRegionName = RegionNameUnderlying
        End Select

    Next
    gSetDefaultStudyConfiguration studyConfig
    Set gGetDefaultStudyConfiguration = studyConfig
End If

Exit Function

Err:
gHandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:=ProcName, pModuleName:=ModuleName
End Function

Public Sub gHandleUnexpectedError( _
                ByRef pProcedureName As String, _
                ByRef pModuleName As String, _
                Optional ByVal pReRaise As Boolean = True, _
                Optional ByVal pLog As Boolean = False, _
                Optional ByRef pFailpoint As String, _
                Optional ByVal pErrorNumber As Long, _
                Optional ByRef pErrorDesc As String, _
                Optional ByRef pErrorSource As String)
Dim errSource As String: errSource = IIf(pErrorSource <> "", pErrorSource, Err.source)
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
Dim errSource As String: errSource = IIf(pErrorSource <> "", pErrorSource, Err.source)
Dim errDesc As String: errDesc = IIf(pErrorDesc <> "", pErrorDesc, Err.Description)
Dim errNum As Long: errNum = IIf(pErrorNumber <> 0, pErrorNumber, Err.Number)

UnhandledErrorHandler.Notify pProcedureName, pModuleName, ProjectName, pFailpoint, errNum, errDesc, errSource
End Sub

Public Sub gLoadDefaultStudyConfigurationsFromConfig( _
                ByVal config As ConfigurationSection)
Dim sc As StudyConfiguration
Dim scSect As ConfigurationSection

Const ProcName As String = "gLoadDefaultStudyConfigurationsFromConfig"
Dim failpoint As String

On Error GoTo Err

Set mConfig = config

Set mDefaultStudyConfigurations = New Collection

For Each scSect In mConfig
    Set sc = New StudyConfiguration
    sc.LoadFromConfig scSect
    mDefaultStudyConfigurations.Add sc, calcDefaultStudyKey(sc.Name, sc.StudyLibraryName)
Next

Exit Sub

Err:
If Err.Number = VBErrorCodes.VbErrElementAlreadyExists Then
    gLogger.Log LogLevelNormal, "Config file contains more than one default configuration for Study " & sc.Name & "(" & sc.StudyLibraryName & ")"
    Resume Next
End If
gHandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:=ProcName, pModuleName:=ModuleName
End Sub

Public Sub gSetDefaultStudyConfiguration( _
                ByVal value As StudyConfiguration)
Dim sc As StudyConfiguration
Dim key As String

Const ProcName As String = "gSetDefaultStudyConfiguration"
Dim failpoint As String
On Error GoTo Err

If mDefaultStudyConfigurations Is Nothing Then
    Set mDefaultStudyConfigurations = New Collection
End If

key = calcDefaultStudyKey(value.Name, value.StudyLibraryName)

On Error Resume Next
Set sc = mDefaultStudyConfigurations(key)
On Error GoTo Err

If Not sc Is Nothing Then
    sc.RemoveFromConfig
    mDefaultStudyConfigurations.Remove key
End If

Set sc = value.Clone
sc.UnderlyingStudy = Nothing
mDefaultStudyConfigurations.Add sc, key
sc.ConfigurationSection = mConfig.AddConfigurationSection(ConfigSectionDefaultStudyConfig & "(" & sc.ID & ")")

Exit Sub

Err:
gHandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:=ProcName, pModuleName:=ModuleName
End Sub

'@================================================================================
' Helper Functions
'@================================================================================

Private Function calcDefaultStudyKey(ByVal studyName As String, ByVal StudyLibraryName As String) As String
calcDefaultStudyKey = "$$" & studyName & "$$" & StudyLibraryName & "$$"
End Function


