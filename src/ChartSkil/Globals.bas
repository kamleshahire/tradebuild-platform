Attribute VB_Name = "Globals"
Option Explicit

'================================================================================
' Constants
'================================================================================

Public Const ProjectName                As String = "ChartSkil26"

Public Const Pi As Double = 3.14159265358979

Public Const MinusInfinityDouble As Double = -(2 - 2 ^ -52) * 2 ^ 1023
Public Const PlusInfinityDouble As Double = (2 - 2 ^ -52) * 2 ^ 1023

Public Const MinusInfinitySingle As Single = -(2 - 2 ^ -23) * 2 ^ 127
Public Const PlusInfinitySingle As Single = (2 - 2 ^ -23) * 2 ^ 127

Public Const OneMicroSecond As Double = 1.15740740740741E-11

Public Const MaxSystemColor As Long = &H80000018

Public Const GridlineSpacingCm As Double = 1.8

Public Const HitTestTolerancePixels As Long = 3

Public Const TwipsPerCm As Double = 1440 / 2.54

Public Const ToolbarCommandAutoScale As String = "autoscale"
Public Const ToolbarCommandAutoscroll As String = "autoscroll"

Public Const ToolbarCommandIncreaseSpacing As String = "increasespacing"
Public Const ToolbarCommandReduceSpacing As String = "reducespacing"

Public Const ToolbarCommandScaleDown As String = "scaledown"
Public Const ToolbarCommandScaleUp As String = "scaleup"

Public Const ToolbarCommandScrollDown As String = "scrolldown"
Public Const ToolbarCommandScrollEnd As String = "scrollend"
Public Const ToolbarCommandScrollLeft As String = "scrollleft"
Public Const ToolbarCommandScrollRight As String = "scrollright"
Public Const ToolbarCommandScrollUp As String = "scrollup"

Public Const ToolbarCommandShowBars As String = "showbars"
Public Const ToolbarCommandShowCandlesticks As String = "showcandlesticks"
Public Const ToolbarCommandShowLine As String = "showline"
Public Const ToolbarCommandShowCrosshair As String = "showcrosshair"
Public Const ToolbarCommandShowPlainCursor As String = "showplaincursor"
Public Const ToolbarCommandShowDiscCursor As String = "showdisccursor"

Public Const ToolbarCommandThickerBars As String = "thickerbars"
Public Const ToolbarCommandThinnerBars As String = "thinnerbars"

'================================================================================
' Enums
'================================================================================

Public Enum DataPointPropertyOverrideFlags
    DataPointIsSetLineThickness = 1
    DataPointIsSetColor = 2
    DataPointIsSetUpColor = 4
    DataPointIsSetDownColor = 8
    DataPointIsSetLineStyle = &H10&
    DataPointIsSetPointStyle = &H20&
    DataPointIsSetDisplayMode = &H40&
    DataPointIsSetHistBarWidth = &H80&
    DataPointIsSetIncludeInAutoscale = &H100&
    DataPointIsSetLayer = &H200&
End Enum

Public Enum LayerNumberRange
    MinLayer = 0
    MaxLayer = 255
End Enum

'================================================================================
' Types
'================================================================================

'================================================================================
' Member variables
'================================================================================

Private mIsInDev As Boolean

Public gBlankCursor As IPictureDisp
Public gSelectorCursor As IPictureDisp

'================================================================================
' Properties
'================================================================================

Public Property Get gIsInDev() As Boolean
gIsInDev = mIsInDev
End Property

Public Property Get gErrorLogger() As Logger
Static lLogger As Logger
If lLogger Is Nothing Then Set lLogger = GetLogger("error")
Set gErrorLogger = lLogger
End Property

Public Property Get gLogger() As Logger
Static lLogger As Logger
If lLogger Is Nothing Then Set lLogger = GetLogger("chartskil.log")
Set gLogger = lLogger
End Property

'================================================================================
' Methods
'================================================================================

Public Function gCloneFont( _
                ByVal pFont As StdFont) As StdFont
Dim aFont As StdFont
Set aFont = New StdFont
aFont.Bold = pFont.Bold
aFont.Charset = pFont.Charset
aFont.Italic = pFont.Italic
aFont.Name = pFont.Name
aFont.size = pFont.size
aFont.Strikethrough = pFont.Strikethrough
aFont.Underline = pFont.Underline
aFont.Weight = pFont.Weight
Set gCloneFont = aFont
End Function

Public Function gIsValidColor( _
                ByVal value As Long) As Boolean
                
If value > &HFFFFFF Then Exit Function
If value < 0 And value > MaxSystemColor Then Exit Function
gIsValidColor = True
End Function

Public Sub Main()
Debug.Print "ChartSkil running in development environment: " & CStr(inDev)
End Sub

'================================================================================
' Helper Functions
'================================================================================

Private Function inDev() As Boolean
mIsInDev = True
inDev = True
End Function

