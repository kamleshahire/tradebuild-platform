VERSION 5.00
Begin VB.Form fConfigEditor 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Configuration editor"
   ClientHeight    =   5175
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   10215
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5175
   ScaleWidth      =   10215
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin TradeSkilDemo26.ConfigManager ConfigManager1 
      Height          =   4095
      Left            =   120
      TabIndex        =   0
      Top             =   480
      Width           =   10095
      _ExtentX        =   17806
      _ExtentY        =   7223
   End
   Begin VB.CommandButton CloseButton 
      Cancel          =   -1  'True
      Caption         =   "Close"
      Height          =   495
      Left            =   9120
      TabIndex        =   2
      Top             =   4560
      Width           =   975
   End
   Begin VB.CommandButton ConfigureButton 
      Caption         =   "Load Selected &Configuration"
      Enabled         =   0   'False
      Height          =   495
      Left            =   360
      TabIndex        =   1
      ToolTipText     =   "Set this configuration"
      Top             =   4560
      Width           =   1815
   End
   Begin VB.TextBox CurrentConfigNameText 
      Height          =   285
      Left            =   3240
      Locked          =   -1  'True
      TabIndex        =   3
      TabStop         =   0   'False
      Top             =   120
      Width           =   3615
   End
   Begin VB.Label Label1 
      Caption         =   "Current configuration is:"
      Height          =   375
      Left            =   1440
      TabIndex        =   4
      Top             =   120
      Width           =   1815
   End
End
Attribute VB_Name = "fConfigEditor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
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

Private Const ModuleName                            As String = "fConfigEditor"

'@================================================================================
' Member variables
'@================================================================================

Private mConfig                                     As ConfigurationSection

'@================================================================================
' Class Event Handlers
'@================================================================================

Private Sub Form_Load()
Const ProcName As String = "Form_Load"

On Error GoTo Err

Set mConfig = gAppInstanceConfig

Me.left = CLng(mConfig.GetSetting(ConfigSettingConfigEditorLeft, 0)) * Screen.TwipsPerPixelX
Me.Top = CLng(mConfig.GetSetting(ConfigSettingConfigEditorTop, (Screen.Height - Me.Height) / Screen.TwipsPerPixelY)) * Screen.TwipsPerPixelY

ConfigManager1.initialise gConfigStore, App.ProductName, ConfigFileVersion

CurrentConfigNameText = mConfig.InstanceQualifier

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName, ProjectName
End Sub

Private Sub Form_QueryUnload(cancel As Integer, UnloadMode As Integer)
Const ProcName As String = "Form_QueryUnload"

On Error GoTo Err

updateSettings

If UnloadMode = vbFormControlMenu Then
    Me.Hide
    cancel = True

End If

If ConfigManager1.changesPending Then
    If MsgBox("Apply outstanding changes?" & vbCrLf & _
            "If you click No, your changes to this configuration item will be lost", _
            vbYesNo Or vbQuestion, _
            "Attention!") = vbYes Then
        ConfigManager1.applyPendingChanges
    End If
End If

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName, ProjectName

End Sub

'@================================================================================
' XXXX Interface Members
'@================================================================================

'@================================================================================
' Control Event Handlers
'@================================================================================

Private Sub CloseButton_Click()
Me.Hide
End Sub

Private Sub ConfigManager1_SelectedItemChanged()
Const ProcName As String = "ConfigManager1_SelectedItemChanged"

On Error GoTo Err

checkOkToLoadConfiguration

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName, ProjectName
End Sub

Private Sub ConfigureButton_Click()
Const ProcName As String = "ConfigureButton_Click"

On Error GoTo Err

updateSettings
If Not gMainForm.LoadConfig(ConfigManager1.selectedAppConfig) Then Me.Hide

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

'@================================================================================
' Helper Functions
'@================================================================================

Private Sub checkOkToLoadConfiguration()
Const ProcName As String = "checkOkToLoadConfiguration"

On Error GoTo Err

If Not ConfigManager1.selectedAppConfig Is Nothing Then
    ConfigureButton.Enabled = True
    ConfigureButton.Default = True
Else
    ConfigureButton.Enabled = False
    CloseButton.Default = True
End If

Exit Sub

Err:
gHandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:=ProcName, pModuleName:=ModuleName
End Sub

Private Sub updateSettings()
Const ProcName As String = "updateSettings"

On Error GoTo Err

If Not mConfig Is Nothing Then
    mConfig.AddPrivateConfigurationSection ConfigSectionConfigEditor
    mConfig.SetSetting ConfigSettingConfigEditorLeft, Me.left / Screen.TwipsPerPixelX
    mConfig.SetSetting ConfigSettingConfigEditorTop, Me.Top / Screen.TwipsPerPixelY
End If

Exit Sub

Err:
gHandleUnexpectedError pReRaise:=True, pLog:=False, pProcedureName:=ProcName, pModuleName:=ModuleName
End Sub


