VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.OCX"
Object = "{86CF1D34-0C5F-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomct2.ocx"
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "ComDlg32.OCX"
Begin VB.UserControl StudyValueConfigurer 
   BackStyle       =   0  'Transparent
   ClientHeight    =   450
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   6885
   ScaleHeight     =   450
   ScaleWidth      =   6885
   Begin MSComDlg.CommonDialog CommonDialog1 
      Left            =   360
      Top             =   120
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin VB.CheckBox IncludeCheck 
      Height          =   195
      Left            =   1560
      TabIndex        =   0
      ToolTipText     =   "Set to include this study value in the chart"
      Top             =   0
      Width           =   195
   End
   Begin VB.TextBox ThicknessText 
      Alignment       =   2  'Center
      Height          =   330
      Left            =   4320
      TabIndex        =   3
      Text            =   "1"
      ToolTipText     =   "Choose the thickness of lines or points"
      Top             =   0
      Width           =   495
   End
   Begin VB.CheckBox AutoscaleCheck 
      Height          =   195
      Left            =   1920
      TabIndex        =   1
      ToolTipText     =   "Set this to ensure that all values are visible when the chart is auto-scaling"
      Top             =   0
      Width           =   210
   End
   Begin VB.CommandButton AdvancedButton 
      Caption         =   "..."
      Height          =   375
      Left            =   6360
      TabIndex        =   7
      ToolTipText     =   "Click for advanced features"
      Top             =   0
      Width           =   495
   End
   Begin VB.CommandButton FontButton 
      Caption         =   "Font..."
      Height          =   375
      Left            =   5400
      TabIndex        =   6
      ToolTipText     =   "Click to select the font"
      Top             =   0
      Width           =   615
   End
   Begin MSComctlLib.ImageCombo StyleCombo 
      Height          =   330
      Left            =   5160
      TabIndex        =   5
      ToolTipText     =   "Choose the line style (ignored if thickness is greater than 1)"
      Top             =   0
      Width           =   1095
      _ExtentX        =   1931
      _ExtentY        =   582
      _Version        =   393216
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      Locked          =   -1  'True
   End
   Begin MSComctlLib.ImageCombo DisplayModeCombo 
      Height          =   330
      Left            =   3240
      TabIndex        =   2
      ToolTipText     =   "Select how to display this value"
      Top             =   0
      Width           =   975
      _ExtentX        =   1720
      _ExtentY        =   582
      _Version        =   393216
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      Locked          =   -1  'True
   End
   Begin MSComCtl2.UpDown ThicknessUpDown 
      Height          =   330
      Left            =   4800
      TabIndex        =   4
      Top             =   0
      Width           =   255
      _ExtentX        =   450
      _ExtentY        =   582
      _Version        =   393216
      Value           =   1
      OrigLeft        =   4080
      OrigTop         =   240
      OrigRight       =   4335
      OrigBottom      =   570
      Min             =   1
      Enabled         =   -1  'True
   End
   Begin VB.Label ValueNameLabel 
      Caption         =   "Label2"
      Height          =   375
      Left            =   0
      TabIndex        =   11
      Top             =   0
      Width           =   1575
   End
   Begin VB.Label ColorLabel 
      Appearance      =   0  'Flat
      BackColor       =   &H00FF0000&
      ForeColor       =   &H80000008&
      Height          =   330
      Left            =   2175
      TabIndex        =   10
      ToolTipText     =   "Click to change the colour for this value"
      Top             =   0
      Width           =   255
   End
   Begin VB.Label UpColorLabel 
      BackColor       =   &H0000FF00&
      Height          =   330
      Left            =   2520
      TabIndex        =   9
      Top             =   0
      Width           =   255
   End
   Begin VB.Label DownColorLabel 
      BackColor       =   &H000000FF&
      Height          =   330
      Left            =   2865
      TabIndex        =   8
      Top             =   0
      Width           =   255
   End
End
Attribute VB_Name = "StudyValueConfigurer"
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

Private Const ModuleName                            As String = "StudyValueConfigurer"

'@================================================================================
' Member variables
'@================================================================================

Private mChartController As ChartController
Private mStudyValueDef As StudyValueDefinition
Private mStudyValueConfig As StudyValueConfiguration

Private mFont As StdFont

'@================================================================================
' Class Event Handlers
'@================================================================================

Private Sub UserControl_Resize()
UserControl.Height = FontButton.Height + 75
UserControl.Width = AdvancedButton.Left + AdvancedButton.Width
End Sub

'@================================================================================
' XXXX Interface Members
'@================================================================================

'@================================================================================
' Control Event Handlers
'@================================================================================

Private Sub AdvancedButton_Click()
Const ProcName As String = "AdvancedButton_Click"
On Error GoTo Err

notImplemented

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName, ProjectName
End Sub

Private Sub ColorLabel_Click()
Const ProcName As String = "ColorLabel_Click"
On Error GoTo Err

ColorLabel.BackColor = gChooseAColor(ColorLabel.BackColor, _
                                    IIf(mStudyValueDef.ValueMode = ValueModeBar, True, False), _
                                    getParentForm)

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName, ProjectName
End Sub

Private Sub DisplayModeCombo_Click()
Const ProcName As String = "DisplayModeCombo_Click"
On Error GoTo Err

Select Case mStudyValueDef.ValueMode
Case ValueModeNone
    Dim dpStyle As DataPointStyle
    
    If Not mStudyValueConfig Is Nothing Then
        Set dpStyle = mStudyValueConfig.DataPointStyle
    Else
        Set dpStyle = GetDefaultDataPointStyle.Clone
    End If
        
    Select Case DisplayModeCombo.SelectedItem.text
    Case PointDisplayModeLine
        initialiseLineStyleCombo StyleCombo, dpStyle.LineStyle
    Case PointDisplayModePoint
        initialisePointStyleCombo StyleCombo, dpStyle.PointStyle
    Case PointDisplayModeSteppedLine
        initialiseLineStyleCombo StyleCombo, dpStyle.LineStyle
    Case PointDisplayModeHistogram
        initialiseHistogramStyleCombo StyleCombo, dpStyle.HistogramBarWidth
    End Select
Case ValueModeLine

Case ValueModeBar

Case ValueModeText

End Select

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName, ProjectName
End Sub

Private Sub DisplayModeCombo_Validate(Cancel As Boolean)
Const ProcName As String = "DisplayModeCombo_Validate"
On Error GoTo Err

If DisplayModeCombo.SelectedItem Is Nothing Then Cancel = True

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName, ProjectName
End Sub

Private Sub DownColorLabel_Click()
Const ProcName As String = "ColorLabel_Click"
On Error GoTo Err

DownColorLabel.BackColor = gChooseAColor(DownColorLabel.BackColor, _
                                        IIf(mStudyValueDef.ValueMode = ValueModeBar, True, False), _
                                        getParentForm)

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName, ProjectName
End Sub

Private Sub FontButton_Click()
Dim aFont As StdFont

Const ProcName As String = "FontButton_Click"
On Error GoTo Err

CommonDialog1.flags = cdlCFBoth + cdlCFEffects
CommonDialog1.FontName = mFont.name
CommonDialog1.FontBold = mFont.Bold
CommonDialog1.FontItalic = mFont.Italic
CommonDialog1.FontSize = mFont.Size
CommonDialog1.FontStrikethru = mFont.Strikethrough
CommonDialog1.FontUnderline = mFont.Underline
CommonDialog1.Color = ColorLabel.BackColor
CommonDialog1.ShowFont

Set aFont = New StdFont
aFont.Bold = CommonDialog1.FontBold
aFont.Italic = CommonDialog1.FontItalic
aFont.name = CommonDialog1.FontName
aFont.Size = CommonDialog1.FontSize
aFont.Strikethrough = CommonDialog1.FontStrikethru
aFont.Underline = CommonDialog1.FontUnderline

Set mFont = aFont

ColorLabel.BackColor = CommonDialog1.Color

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName, ProjectName
End Sub

Private Sub StyleCombo_Validate(Cancel As Boolean)
Const ProcName As String = "StyleCombo_Validate"
On Error GoTo Err

If StyleCombo.SelectedItem Is Nothing Then Cancel = True

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName, ProjectName
End Sub

Private Sub ThicknessText_KeyPress(KeyAscii As Integer)
Const ProcName As String = "ThicknessText_KeyPress"
On Error GoTo Err

filterNonNumericKeyPress KeyAscii

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName, ProjectName
End Sub

Private Sub UpColorLabel_Click()
Const ProcName As String = "ColorLabel_Click"
On Error GoTo Err

UpColorLabel.BackColor = gChooseAColor(UpColorLabel.BackColor, _
                                        IIf(mStudyValueDef.ValueMode = ValueModeBar, True, False), _
                                        getParentForm)

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName, ProjectName
End Sub

'@================================================================================
' XXXX Event Handlers
'@================================================================================

'@================================================================================
' Properties
'@================================================================================

'@================================================================================
' Methods
'@================================================================================

Public Sub ApplyUpdates(ByVal pStudyValueConfig As StudyValueConfiguration)
Const ProcName As String = "ApplyUpdates"
On Error GoTo Err

If Not mStudyValueConfig Is Nothing Then
    pStudyValueConfig.BarFormatterFactoryName = mStudyValueConfig.BarFormatterFactoryName
    pStudyValueConfig.BarFormatterLibraryName = mStudyValueConfig.BarFormatterLibraryName
End If

pStudyValueConfig.IncludeInChart = (IncludeCheck.value = vbChecked)

pStudyValueConfig.ChartRegionName = getRegionName

Select Case mStudyValueDef.ValueMode
Case ValueModeNone
    Dim dpStyle As DataPointStyle
    
    Set dpStyle = GetDefaultDataPointStyle.Clone
    
    dpStyle.IncludeInAutoscale = (AutoscaleCheck.value = vbChecked)
    dpStyle.Color = ColorLabel.BackColor
    dpStyle.DownColor = IIf(DownColorLabel.BackColor = NullColor, _
                        -1, _
                        DownColorLabel.BackColor)
    dpStyle.UpColor = IIf(UpColorLabel.BackColor = NullColor, _
                        -1, _
                        UpColorLabel.BackColor)
    
    Select Case DisplayModeCombo.SelectedItem.text
    Case PointDisplayModeLine
        dpStyle.DisplayMode = DataPointDisplayModes.DataPointDisplayModeLine
        Select Case StyleCombo.SelectedItem.text
        Case LineStyleSolid
            dpStyle.LineStyle = LineSolid
        Case LineStyleDash
            dpStyle.LineStyle = LineDash
        Case LineStyleDot
            dpStyle.LineStyle = LineDot
        Case LineStyleDashDot
            dpStyle.LineStyle = LineDashDot
        Case LineStyleDashDotDot
            dpStyle.LineStyle = LineDashDotDot
        End Select
    Case PointDisplayModePoint
        dpStyle.DisplayMode = DataPointDisplayModes.DataPointDisplayModePoint
        Select Case StyleCombo.SelectedItem.text
        Case PointStyleRound
            dpStyle.PointStyle = PointRound
        Case PointStyleSquare
            dpStyle.PointStyle = PointSquare
        End Select
    Case PointDisplayModeSteppedLine
        dpStyle.DisplayMode = DataPointDisplayModes.DataPointDisplayModeStep
        Select Case StyleCombo.SelectedItem.text
        Case LineStyleSolid
            dpStyle.LineStyle = LineSolid
        Case LineStyleDash
            dpStyle.LineStyle = LineDash
        Case LineStyleDot
            dpStyle.LineStyle = LineDot
        Case LineStyleDashDot
            dpStyle.LineStyle = LineDashDot
        Case LineStyleDashDotDot
            dpStyle.LineStyle = LineDashDotDot
        End Select
    Case PointDisplayModeHistogram
        dpStyle.DisplayMode = DataPointDisplayModes.DataPointDisplayModeHistogram
        Select Case StyleCombo.SelectedItem.text
        Case HistogramStyleNarrow
            dpStyle.HistogramBarWidth = HistogramWidthNarrow
        Case HistogramStyleMedium
            dpStyle.HistogramBarWidth = HistogramWidthMedium
        Case HistogramStyleWide
            dpStyle.HistogramBarWidth = HistogramWidthWide
        Case CustomStyle
            dpStyle.HistogramBarWidth = CSng(StyleCombo.SelectedItem.Tag)
        End Select
    End Select
    
    dpStyle.LineThickness = ThicknessText.text
    
    pStudyValueConfig.DataPointStyle = dpStyle
Case ValueModeLine
    Dim lnStyle As LineStyle

    Set lnStyle = GetDefaultLineStyle.Clone
    
    lnStyle.IncludeInAutoscale = (AutoscaleCheck.value = vbChecked)
    lnStyle.Color = ColorLabel.BackColor
    lnStyle.ArrowStartColor = ColorLabel.BackColor
    lnStyle.ArrowEndColor = ColorLabel.BackColor
    lnStyle.ArrowStartFillColor = IIf(UpColorLabel.BackColor = NullColor, _
                                    -1, _
                                    UpColorLabel.BackColor)
    lnStyle.ArrowEndFillColor = IIf(DownColorLabel.BackColor = NullColor, _
                                    -1, _
                                    DownColorLabel.BackColor)
    
    Select Case DisplayModeCombo.SelectedItem.text
    Case LineDisplayModePlain
        lnStyle.ArrowEndStyle = ArrowNone
        lnStyle.ArrowStartStyle = ArrowNone
    Case LineDisplayModeArrowEnd
        lnStyle.ArrowEndStyle = ArrowClosed
        lnStyle.ArrowStartStyle = ArrowNone
    Case LineDisplayModeArrowStart
        lnStyle.ArrowEndStyle = ArrowNone
        lnStyle.ArrowStartStyle = ArrowClosed
    Case LineDisplayModeArrowBoth
        lnStyle.ArrowEndStyle = ArrowClosed
        lnStyle.ArrowStartStyle = ArrowClosed
    End Select
        
    Select Case StyleCombo.SelectedItem.text
    Case LineStyleSolid
        lnStyle.LineStyle = LineSolid
    Case LineStyleDash
        lnStyle.LineStyle = LineDash
    Case LineStyleDot
        lnStyle.LineStyle = LineDot
    Case LineStyleDashDot
        lnStyle.LineStyle = LineDashDot
    Case LineStyleDashDotDot
        lnStyle.LineStyle = LineDashDotDot
    End Select
    
    lnStyle.Thickness = ThicknessText.text
    ' temporary fix until ChartSkil improves drawing of non-extended lines
    lnStyle.Extended = True
    
    pStudyValueConfig.LineStyle = lnStyle

Case ValueModeBar
    Dim brStyle As BarStyle
    
    Set brStyle = GetDefaultBarStyle.Clone
    
    brStyle.IncludeInAutoscale = (AutoscaleCheck.value = vbChecked)
    brStyle.Color = IIf(ColorLabel.BackColor = NullColor, _
                        -1, _
                        ColorLabel.BackColor)
    brStyle.DownColor = IIf(DownColorLabel.BackColor = NullColor, _
                        -1, _
                        DownColorLabel.BackColor)
    brStyle.UpColor = UpColorLabel.BackColor
    
    Select Case DisplayModeCombo.SelectedItem.text
    Case BarModeBar
        brStyle.DisplayMode = BarDisplayModes.BarDisplayModeBar
        brStyle.Thickness = ThicknessText.text
    Case BarModeCandle
        brStyle.DisplayMode = BarDisplayModes.BarDisplayModeCandlestick
        brStyle.SolidUpBody = False
        brStyle.TailThickness = ThicknessText.text
    Case BarModeSolidCandle
        brStyle.DisplayMode = BarDisplayModes.BarDisplayModeCandlestick
        brStyle.SolidUpBody = True
        brStyle.TailThickness = ThicknessText.text
    Case BarModeLine
        brStyle.DisplayMode = BarDisplayModes.BarDisplayModeLine
    End Select
    
    Select Case StyleCombo.SelectedItem.text
    Case BarStyleNarrow
        brStyle.Width = BarWidthNarrow
    Case BarStyleMedium
        brStyle.Width = BarWidthMedium
    Case BarStyleWide
        brStyle.Width = BarWidthWide
    Case CustomStyle
        brStyle.Width = CSng(StyleCombo.SelectedItem.Tag)
    End Select
    
    pStudyValueConfig.BarStyle = brStyle

Case ValueModeText
    Dim txStyle As TextStyle

    Set txStyle = GetDefaultTextStyle.Clone
    
    txStyle.IncludeInAutoscale = (AutoscaleCheck.value = vbChecked)
    txStyle.Color = ColorLabel.BackColor
    txStyle.BoxFillColor = IIf(UpColorLabel.BackColor = NullColor, _
                                    -1, _
                                    UpColorLabel.BackColor)
    txStyle.BoxColor = IIf(DownColorLabel.BackColor = NullColor, _
                                    -1, _
                                    DownColorLabel.BackColor)
    
    Select Case DisplayModeCombo.SelectedItem.text
    Case TextDisplayModePlain
        txStyle.Box = False
    Case TextDisplayModeWIthBackground
        txStyle.Box = True
        txStyle.BoxStyle = LineInvisible
        txStyle.BoxFillStyle = FillSolid
    Case TextDisplayModeWithBox
        txStyle.Box = True
        txStyle.BoxStyle = LineInsideSolid
        txStyle.BoxFillStyle = FillTransparent
    Case TextDisplayModeWithFilledBox
        txStyle.Box = True
        txStyle.BoxStyle = LineInsideSolid
        txStyle.BoxFillStyle = FillSolid
    End Select
        
    If TypeName(FontButton.Tag) <> "Nothing" Then
        txStyle.Font = mFont
    End If
    
    txStyle.BoxThickness = ThicknessText.text
    ' temporary fix until ChartSkil improves drawing of non-extended texts
    txStyle.Extended = True
    
    pStudyValueConfig.TextStyle = txStyle


End Select
    
Exit Sub

Err:
gHandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:=ProcName, pModuleName:=ModuleName
End Sub

Public Sub Initialise( _
                ByVal pStudyValueDef As StudyValueDefinition, _
                ByVal pStudyValueConfig As StudyValueConfiguration, _
                ByVal pChartController As ChartController)
Const ProcName As String = "Initialise"
On Error GoTo Err

DownColorLabel.Visible = False
DisplayModeCombo.Visible = False
FontButton.Visible = False
StyleCombo.Visible = False
ThicknessUpDown.Visible = False
UpColorLabel.Visible = False

Set mStudyValueDef = pStudyValueDef
Set mStudyValueConfig = pStudyValueConfig
Set mChartController = pChartController

AutoscaleCheck = vbUnchecked

ValueNameLabel.Caption = mStudyValueDef.name
ValueNameLabel.ToolTipText = mStudyValueDef.Description

If Not mStudyValueConfig Is Nothing Then
    IncludeCheck = IIf(mStudyValueConfig.IncludeInChart, vbChecked, vbUnchecked)
Else
    IncludeCheck = IIf(mStudyValueDef.IncludeInChart, vbChecked, vbUnchecked)
End If
    
Select Case mStudyValueDef.ValueMode
Case ValueModeNone
    Dim dpStyle As DataPointStyle
    
    ColorLabel.ToolTipText = "Select the color for all values"
    
    UpColorLabel.Visible = True
    UpColorLabel.ToolTipText = "Optionally, select the color for higher values"
    
    DownColorLabel.Visible = True
    DownColorLabel.ToolTipText = "Optionally, select the color for lower values"
    
    DisplayModeCombo.Visible = True
    StyleCombo.Visible = True
    
    If Not mStudyValueConfig Is Nothing Then
        Set dpStyle = mStudyValueConfig.DataPointStyle
    ElseIf Not mStudyValueDef.ValueStyle Is Nothing Then
        Set dpStyle = mStudyValueDef.ValueStyle
    End If
    If dpStyle Is Nothing Then Set dpStyle = GetDefaultDataPointStyle.Clone
    
    AutoscaleCheck = IIf(dpStyle.IncludeInAutoscale, vbChecked, vbUnchecked)
    ColorLabel.BackColor = dpStyle.Color
    UpColorLabel.BackColor = IIf(dpStyle.UpColor = -1, NullColor, dpStyle.UpColor)
    DownColorLabel.BackColor = IIf(dpStyle.DownColor = -1, NullColor, dpStyle.DownColor)
    
    initialisePointDisplayModeCombo DisplayModeCombo, dpStyle.DisplayMode
    Select Case dpStyle.DisplayMode
    Case DataPointDisplayModes.DataPointDisplayModeLine
        initialiseLineStyleCombo StyleCombo, dpStyle.LineStyle
    Case DataPointDisplayModes.DataPointDisplayModePoint
        initialisePointStyleCombo StyleCombo, dpStyle.PointStyle
    Case DataPointDisplayModes.DataPointDisplayModeStep
        initialiseLineStyleCombo StyleCombo, dpStyle.LineStyle
    Case DataPointDisplayModes.DataPointDisplayModeHistogram
        initialiseHistogramStyleCombo StyleCombo, dpStyle.HistogramBarWidth
    End Select
    
    ThicknessText.text = dpStyle.LineThickness
    
Case ValueModeLine
    Dim lnStyle As LineStyle
    
    ColorLabel.ToolTipText = "Select the color for the line"
    
    UpColorLabel.Visible = True
    UpColorLabel.ToolTipText = "Optionally, select the color for the start arrowhead"
    
    DownColorLabel.Visible = True
    DownColorLabel.ToolTipText = "Optionally, select the color for the end arrowhead"
    
    DisplayModeCombo.Visible = True
    StyleCombo.Visible = True
    
    If Not mStudyValueConfig Is Nothing Then
        Set lnStyle = mStudyValueConfig.LineStyle
    ElseIf Not mStudyValueDef.ValueStyle Is Nothing Then
        Set lnStyle = mStudyValueDef.ValueStyle
    End If
    If lnStyle Is Nothing Then Set lnStyle = GetDefaultLineStyle.Clone
    
    AutoscaleCheck = IIf(lnStyle.IncludeInAutoscale, vbChecked, vbUnchecked)
    ColorLabel.BackColor = lnStyle.Color
    UpColorLabel.BackColor = IIf(lnStyle.ArrowStartFillColor = -1, NullColor, lnStyle.ArrowStartFillColor)
    DownColorLabel.BackColor = IIf(lnStyle.ArrowEndFillColor = -1, NullColor, lnStyle.ArrowEndFillColor)
    
    initialiseLineDisplayModeCombo DisplayModeCombo, _
                                    (lnStyle.ArrowStartStyle <> ArrowNone), _
                                    (lnStyle.ArrowEndStyle <> ArrowNone)

    initialiseLineStyleCombo StyleCombo, lnStyle.LineStyle
    
    ThicknessText.text = lnStyle.Thickness
    
Case ValueModeBar
    Dim brStyle As BarStyle
    
    ColorLabel.ToolTipText = "Optionally, select the color for the bar or the candlestick frame"
    
    UpColorLabel.Visible = True
    UpColorLabel.ToolTipText = "Select the color for up bars"
    
    DownColorLabel.Visible = True
    DownColorLabel.ToolTipText = "Optionally, select the color for down bars"
    
    DisplayModeCombo.Visible = True
    StyleCombo.Visible = True
    
    If Not mStudyValueConfig Is Nothing Then
        Set brStyle = mStudyValueConfig.BarStyle
    ElseIf Not mStudyValueDef.ValueStyle Is Nothing Then
        Set brStyle = mStudyValueDef.ValueStyle
    End If
    If brStyle Is Nothing Then Set brStyle = GetDefaultBarStyle.Clone
    
    AutoscaleCheck = IIf(brStyle.IncludeInAutoscale, vbChecked, vbUnchecked)
    ColorLabel.BackColor = IIf(brStyle.Color = -1, NullColor, brStyle.Color)
    UpColorLabel.BackColor = IIf(brStyle.UpColor = -1, NullColor, brStyle.UpColor)
    DownColorLabel.BackColor = IIf(brStyle.DownColor = -1, NullColor, brStyle.DownColor)
    
    initialiseBarDisplayModeCombo DisplayModeCombo, _
                                    brStyle.DisplayMode, _
                                    brStyle.SolidUpBody
    
    initialiseBarStyleCombo StyleCombo, brStyle.Width
    
    Select Case DisplayModeCombo.SelectedItem.text
    Case BarModeBar
        ThicknessText.text = brStyle.Thickness
    Case BarModeCandle
        ThicknessText.text = brStyle.TailThickness
    Case BarModeSolidCandle
        ThicknessText.text = brStyle.TailThickness
    Case BarModeLine
        ThicknessText.text = brStyle.Thickness
    End Select
    
Case ValueModeText
    Dim txStyle As TextStyle
    
    ColorLabel.ToolTipText = "Select the color for the text"
    
    UpColorLabel.Visible = True      ' box fill color
    UpColorLabel.ToolTipText = "Optionally, select the color for the box fill"
    
    DownColorLabel.Visible = True    ' box outline color
    UpColorLabel.ToolTipText = "Optionally, select the color for the box outline"
    
    DisplayModeCombo.Visible = True
    StyleCombo.Visible = False
    FontButton.Visible = True
    
    If Not mStudyValueConfig Is Nothing Then
        Set txStyle = mStudyValueConfig.TextStyle
    ElseIf Not mStudyValueDef.ValueStyle Is Nothing Then
        Set txStyle = mStudyValueDef.ValueStyle
    End If
    If txStyle Is Nothing Then Set txStyle = GetDefaultTextStyle.Clone
    
    AutoscaleCheck = IIf(txStyle.IncludeInAutoscale, vbChecked, vbUnchecked)
    ColorLabel.BackColor = txStyle.Color
    UpColorLabel.BackColor = IIf(txStyle.BoxFillColor = -1, NullColor, txStyle.BoxFillColor)
    DownColorLabel.BackColor = IIf(txStyle.BoxColor = -1, NullColor, txStyle.BoxColor)
    
    initialiseTextDisplayModeCombo DisplayModeCombo, _
                                    txStyle.Box, _
                                    txStyle.BoxThickness, _
                                    txStyle.BoxStyle, _
                                    txStyle.BoxColor, _
                                    txStyle.BoxFillStyle, _
                                    txStyle.BoxFillColor

    ThicknessText.text = txStyle.BoxThickness
    
    Set mFont = txStyle.Font
    
End Select

Exit Sub

Err:
gHandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:=ProcName, pModuleName:=ModuleName
End Sub

'@================================================================================
' Helper Functions
'@================================================================================

Private Function getDefaultRegionName() As String
Select Case mStudyValueDef.DefaultRegion
Case StudyValueDefaultRegionNone
    getDefaultRegionName = ChartRegionNameDefault
Case StudyValueDefaultRegionDefault
    getDefaultRegionName = ChartRegionNameDefault
Case StudyValueDefaultRegionCustom
    getDefaultRegionName = ChartRegionNameCustom
Case StudyValueDefaultRegionUnderlying
    getDefaultRegionName = ChartRegionNameUnderlying
End Select
End Function

Private Function getParentForm() As Form
Dim lParent As Object

Const ProcName As String = "getParentForm"
On Error GoTo Err

Set lParent = UserControl.Parent

Do While Not TypeOf lParent Is Form
    If TypeOf lParent Is StudyConfigurer Then
        Dim sc As StudyConfigurer
        Set sc = lParent
        Set lParent = sc.Parent
    ElseIf TypeOf lParent Is PictureBox Then
        Dim pb As PictureBox
        Set pb = lParent
        Set lParent = pb.Parent
    ElseIf TypeOf lParent Is Frame Then
        Dim fr As Frame
        Set fr = lParent
        Set lParent = fr.Parent
    Else
        Err.Raise ErrorCodes.ErrIllegalStateException, , "No parent form found"
    End If
Loop

Exit Function

Err:
gHandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:=ProcName, pModuleName:=ModuleName
End Function

Private Function getRegionName() As String
If useCurrentRegionName Then
    getRegionName = mStudyValueConfig.ChartRegionName
Else
    getRegionName = getDefaultRegionName
End If
End Function

Private Sub initialiseBarDisplayModeCombo( _
                ByVal combo As ImageCombo, _
                ByVal pDisplayMode As BarDisplayModes, _
                ByVal pSolid As Boolean)
Dim item As ComboItem
Const ProcName As String = "initialiseBarDisplayModeCombo"
On Error GoTo Err

combo.ComboItems.Clear

Set item = combo.ComboItems.Add(, , BarModeBar)
If pDisplayMode = BarDisplayModeBar Then item.selected = True

Set item = combo.ComboItems.Add(, , BarModeCandle)
If pDisplayMode = BarDisplayModeCandlestick And Not pSolid Then item.selected = True

Set item = combo.ComboItems.Add(, , BarModeSolidCandle)
If pDisplayMode = BarDisplayModeCandlestick And pSolid Then item.selected = True

Set item = combo.ComboItems.Add(, , BarModeLine)
If pDisplayMode = BarDisplayModeLine Then item.selected = True

combo.ToolTipText = "Select the type of bar"

combo.Refresh

Exit Sub

Err:
gHandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:=ProcName, pModuleName:=ModuleName
End Sub

Private Sub initialiseBarStyleCombo( _
                ByVal combo As ImageCombo, _
                ByVal barWidth As Single)
Dim item As ComboItem
Dim selected As Boolean

Const ProcName As String = "initialiseBarStyleCombo"
On Error GoTo Err

combo.ComboItems.Clear

Set item = combo.ComboItems.Add(, , BarStyleMedium)
If barWidth = BarWidthMedium Then item.selected = True: selected = True

Set item = combo.ComboItems.Add(, , BarStyleNarrow)
If barWidth = BarWidthNarrow Then item.selected = True: selected = True

Set item = combo.ComboItems.Add(, , BarStyleWide)
If barWidth = BarWidthWide Then item.selected = True: selected = True

If Not selected Then
    Set item = combo.ComboItems.Add(1, , CustomStyle)
    item.selected = True
    item.Tag = barWidth
End If

combo.ToolTipText = "Select the width of the bar"

combo.Refresh

Exit Sub

Err:
gHandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:=ProcName, pModuleName:=ModuleName
End Sub

Private Sub initialiseHistogramStyleCombo( _
                ByVal combo As ImageCombo, _
                ByVal histBarWidth As Single)
Dim item As ComboItem
Dim selected As Boolean

Const ProcName As String = "initialiseHistogramStyleCombo"
On Error GoTo Err

combo.ComboItems.Clear

Set item = combo.ComboItems.Add(, , HistogramStyleMedium)
If histBarWidth = HistogramWidthMedium Then item.selected = True: selected = True

Set item = combo.ComboItems.Add(, , HistogramStyleNarrow)
If histBarWidth = HistogramWidthNarrow Then item.selected = True: selected = True

Set item = combo.ComboItems.Add(, , HistogramStyleWide)
If histBarWidth = HistogramWidthWide Then item.selected = True: selected = True

If Not selected Then
    Set item = combo.ComboItems.Add(1, , CustomStyle)
    item.selected = True
    item.Tag = histBarWidth
End If

combo.ToolTipText = "Select the width of the histogram"

combo.Refresh

Exit Sub

Err:
gHandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:=ProcName, pModuleName:=ModuleName
End Sub

Private Sub initialiseLineDisplayModeCombo( _
                ByVal combo As ImageCombo, _
                ByVal pArrowStart As Boolean, _
                ByVal pArrowEnd As Boolean)
Dim item As ComboItem
Const ProcName As String = "initialiseLineDisplayModeCombo"
On Error GoTo Err

combo.ComboItems.Clear

Set item = combo.ComboItems.Add(, , LineDisplayModePlain)
If Not pArrowStart And Not pArrowEnd Then item.selected = True

Set item = combo.ComboItems.Add(, , LineDisplayModeArrowEnd)
If Not pArrowStart And pArrowEnd Then item.selected = True

Set item = combo.ComboItems.Add(, , LineDisplayModeArrowStart)
If pArrowStart And Not pArrowEnd Then item.selected = True

Set item = combo.ComboItems.Add(, , LineDisplayModeArrowBoth)
If pArrowStart And pArrowEnd Then item.selected = True

combo.ToolTipText = "Select the type of line"

combo.Refresh

Exit Sub

Err:
gHandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:=ProcName, pModuleName:=ModuleName
End Sub

Private Sub initialiseLineStyleCombo( _
                ByVal combo As ImageCombo, _
                ByVal pLineStyle As LineStyles)
Dim item As ComboItem

Const ProcName As String = "initialiseLineStyleCombo"
On Error GoTo Err

combo.ComboItems.Clear

Set item = combo.ComboItems.Add(, , LineStyleSolid)
If pLineStyle = LineSolid Then item.selected = True

Set item = combo.ComboItems.Add(, , LineStyleDash)
If pLineStyle = LineDash Then item.selected = True

Set item = combo.ComboItems.Add(, , LineStyleDot)
If pLineStyle = LineDot Then item.selected = True

Set item = combo.ComboItems.Add(, , LineStyleDashDot)
If pLineStyle = LineDashDot Then item.selected = True

Set item = combo.ComboItems.Add(, , LineStyleDashDotDot)
If pLineStyle = LineDashDotDot Then item.selected = True

combo.ToolTipText = "Select the style of the line"

combo.Refresh

Exit Sub

Err:
gHandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:=ProcName, pModuleName:=ModuleName
End Sub

Private Sub initialisePointDisplayModeCombo( _
                ByVal combo As ImageCombo, _
                ByVal pDisplayMode As DataPointDisplayModes)
Dim item As ComboItem

Const ProcName As String = "initialisePointDisplayModeCombo"
On Error GoTo Err

combo.ComboItems.Clear

Set item = combo.ComboItems.Add(, , PointDisplayModeLine)
If pDisplayMode = DataPointDisplayModeLine Then item.selected = True

Set item = combo.ComboItems.Add(, , PointDisplayModePoint)
If pDisplayMode = DataPointDisplayModePoint Then item.selected = True

Set item = combo.ComboItems.Add(, , PointDisplayModeSteppedLine)
If pDisplayMode = DataPointDisplayModeStep Then item.selected = True

Set item = combo.ComboItems.Add(, , PointDisplayModeHistogram)
If pDisplayMode = DataPointDisplayModeHistogram Then item.selected = True

combo.Refresh

Exit Sub

Err:
gHandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:=ProcName, pModuleName:=ModuleName
End Sub

Private Sub initialisePointStyleCombo( _
                ByVal combo As ImageCombo, _
                ByVal pPointStyle As PointStyles)
Dim item As ComboItem

Const ProcName As String = "initialisePointStyleCombo"
On Error GoTo Err

combo.ComboItems.Clear

Set item = combo.ComboItems.Add(, , PointStyleRound)
If pPointStyle = PointRound Then item.selected = True

Set item = combo.ComboItems.Add(, , PointStyleSquare)
If pPointStyle = PointSquare Then item.selected = True

combo.ToolTipText = "Select the shape of the point"

combo.Refresh

Exit Sub

Err:
gHandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:=ProcName, pModuleName:=ModuleName
End Sub

Private Sub initialiseTextDisplayModeCombo( _
                ByVal combo As ImageCombo, _
                ByVal pBox As Boolean, _
                ByVal pBoxThickness As Long, _
                ByVal pBoxStyle As LineStyles, _
                ByVal pBoxColor As Long, _
                ByVal pBoxFillStyle As FillStyles, _
                ByVal pBoxFillColor As Long)
Dim item As ComboItem
Dim selected As Boolean

Const ProcName As String = "initialiseTextDisplayModeCombo"
On Error GoTo Err

combo.ComboItems.Clear

Set item = combo.ComboItems.Add(, , TextDisplayModePlain)
If Not pBox Then item.selected = True: selected = True

Set item = combo.ComboItems.Add(, , TextDisplayModeWIthBackground)
If pBox And (pBoxStyle = LineInvisible Or pBoxThickness = 0) And pBoxFillStyle = FillSolid Then item.selected = True: selected = True

Set item = combo.ComboItems.Add(, , TextDisplayModeWithBox)
If pBox And pBoxStyle <> LineInvisible And pBoxThickness = 0 And pBoxFillStyle = FillTransparent Then item.selected = True: selected = True

Set item = combo.ComboItems.Add(, , TextDisplayModeWithFilledBox)
If pBox And pBoxStyle <> LineInvisible And pBoxThickness = 0 And pBoxFillStyle = FillSolid Then item.selected = True: selected = True

If Not selected Then
    Set item = combo.ComboItems.Add(, , CustomDisplayMode)
End If

combo.ToolTipText = "Select the type of text"

combo.Refresh

Exit Sub

Err:
gHandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:=ProcName, pModuleName:=ModuleName
End Sub

Private Function useCurrentRegionName() As Boolean
If mStudyValueConfig Is Nothing Then Exit Function
If mStudyValueConfig.ChartRegionName <> "" Then useCurrentRegionName = True
End Function

