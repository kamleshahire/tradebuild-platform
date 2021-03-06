VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "BracketOrderSummary"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

'@================================================================================
' Description
'@================================================================================
'
'

'@================================================================================
' Interfaces
'@================================================================================

Implements IJSONable

'@================================================================================
' Events
'@================================================================================

'@================================================================================
' Constants
'@================================================================================

Private Const ModuleName                As String = "BracketOrderSummary"

'@================================================================================
' Enums
'@================================================================================

'@================================================================================
' Types
'@================================================================================

'@================================================================================
' Member variables
'@================================================================================

'Private mContextsName                        As String
Private mContextName                        As String
'Private mGroupName As String

Private mState As BracketOrderStates
Private mKey As String

Private mDescription As String
Private mEntryReason As String
Private mTargetReason As String
Private mStopReason As String

Private mSize As Long

Private mCancelPrice As Double
Private mCancelTime As Date

Private mEntryOrderId As String
Attribute mEntryOrderId.VB_VarHelpID = -1
Private mStopLossOrderId As String
Attribute mStopLossOrderId.VB_VarHelpID = -1
Private mTargetOrderId As String
Attribute mTargetOrderId.VB_VarHelpID = -1
Private mCloseoutOrderId As String
Attribute mCloseoutOrderId.VB_VarHelpID = -1

Private mCreationTime As Date

Private mPreventUnprotectedPosition As Boolean

Private mCumBuyPrice As Double
Private mCumSellPrice As Double

Private mIsDirty As Boolean

'@================================================================================
' Class Event Handlers
'@================================================================================

'@================================================================================
' IJSONAble Interface Members
'@================================================================================

Private Function IJSONAble_ToJSON() As String
IJSONAble_ToJSON = ToJSON
End Function

'@================================================================================
' XXXX Event Handlers
'@================================================================================

'@================================================================================
' Properties
'@================================================================================

Public Property Let CancelPrice(ByVal Value As Double)
If mCancelPrice <> Value Then setDirty
mCancelPrice = Value
End Property

Public Property Get CancelPrice() As Double
CancelPrice = mCancelPrice
End Property

Public Property Let CancelTime(ByVal Value As Date)
If mCancelTime <> Value Then setDirty
mCancelTime = Value
End Property

Public Property Get CancelTime() As Date
CancelTime = mCancelTime
End Property

Public Property Let CloseoutOrderId(ByVal Value As String)
If CloseoutOrderId <> Value Then setDirty
mCloseoutOrderId = Value
End Property

Public Property Get CloseoutOrderId() As String
CloseoutOrderId = mCloseoutOrderId
End Property

Public Property Let ContextName(ByVal Value As String)
If mContextName <> Value Then setDirty
mContextName = Value
End Property

Public Property Get ContextName() As String
ContextName = mContextName
End Property

'Public Property Let ContextsName(ByVal Value As String)
'If mContextsName <> Value Then setDirty
'mContextsName = Value
'End Property
'
'Public Property Get ContextsName() As String
'ContextsName = mContextsName
'End Property

Public Property Let CreationTime(ByVal Value As Date)
If mCreationTime <> Value Then setDirty
mCreationTime = Value
End Property

Public Property Get CreationTime() As Date
CreationTime = mCreationTime
End Property

Public Property Let CumBuyPrice(ByVal Value As Double)
If mCumBuyPrice <> Value Then setDirty
mCumBuyPrice = Value
End Property

Public Property Get CumBuyPrice() As Double
CumBuyPrice = mCumBuyPrice
End Property

Public Property Let CumSellPrice(ByVal Value As Double)
If mCumSellPrice <> Value Then setDirty
mCumSellPrice = Value
End Property

Public Property Get CumSellPrice() As Double
CumSellPrice = mCumSellPrice
End Property

Public Property Let Description(ByVal Value As String)
If mDescription <> Value Then setDirty
mDescription = Value
End Property

Public Property Get Description() As String
Description = mDescription
End Property

Public Property Let EntryOrderId(ByVal Value As String)
If mEntryOrderId <> Value Then setDirty
mEntryOrderId = Value
End Property

Public Property Get EntryOrderId() As String
EntryOrderId = mEntryOrderId
End Property

Public Property Let EntryReason(ByVal Value As String)
If mEntryReason <> Value Then setDirty
mEntryReason = Value
End Property

Public Property Get EntryReason() As String
EntryReason = mEntryReason
End Property

'Public Property Let GroupName(ByVal Value As String)
'If mGroupName <> Value Then setDirty
'mGroupName = Value
'End Property
'
'Public Property Get GroupName() As String
'GroupName = mGroupName
'End Property

Public Property Get IsDirty() As Boolean
IsDirty = mIsDirty
End Property

Public Property Let Key(ByVal Value As String)
If mKey <> Value Then setDirty
mKey = Value
End Property

Public Property Get Key() As String
Key = mKey
End Property

Public Property Let PreventUnprotectedPosition(ByVal Value As Boolean)
If mPreventUnprotectedPosition <> Value Then setDirty
mPreventUnprotectedPosition = Value
End Property

Public Property Get PreventUnprotectedPosition() As Boolean
PreventUnprotectedPosition = mPreventUnprotectedPosition
End Property

Public Property Let Size(ByVal Value As Long)
If mSize <> Value Then setDirty
mSize = Value
End Property

Public Property Get Size() As Long
Size = mSize
End Property

Public Property Let State(ByVal Value As BracketOrderStates)
If mState <> Value Then setDirty
mState = Value
End Property

Public Property Get State() As BracketOrderStates
State = mState
End Property

Public Property Let StopLossOrderId(ByVal Value As String)
If mStopLossOrderId <> Value Then setDirty
mStopLossOrderId = Value
End Property

Public Property Get StopLossOrderId() As String
StopLossOrderId = mStopLossOrderId
End Property

Public Property Let StopReason(ByVal Value As String)
If mStopReason <> Value Then setDirty
mStopReason = Value
End Property

Public Property Get StopReason() As String
StopReason = mStopReason
End Property

Public Property Let TargetOrderId(ByVal Value As String)
If mTargetOrderId <> Value Then setDirty
mTargetOrderId = Value
End Property

Public Property Get TargetOrderId() As String
TargetOrderId = mTargetOrderId
End Property

Public Property Let TargetReason(ByVal Value As String)
If mTargetReason <> Value Then setDirty
mTargetReason = Value
End Property

Public Property Get TargetReason() As String
TargetReason = mTargetReason
End Property

'@================================================================================
' Methods
'@================================================================================

Friend Sub setClean()
mIsDirty = False
End Sub

Friend Function ToJSON() As String
Dim jb As JSONBuilder
Set jb = New JSONBuilder

jb.BeginObject

jb.EncodeName "$ProgID"
jb.EncodeValue ProjectName & "." & ModuleName

jb.EncodeNameAndValue "CancelPrice", mCancelPrice, 0#

jb.EncodeNameAndValue "CancelTime", mCancelTime, CDate(0#)

jb.EncodeNameAndValue "CloseoutOrderId", mCloseoutOrderId, ""

jb.EncodeName "ContextName"
jb.EncodeValue mContextName

'jb.EncodeName "ContextsName"
'jb.EncodeValue mContextsName

jb.EncodeName "CreationTime"
jb.EncodeValue mCreationTime

jb.EncodeNameAndValue "CumBuyPrice", mCumBuyPrice, 0#

jb.EncodeNameAndValue "CumSellPrice", mCumSellPrice, 0#

jb.EncodeNameAndValue "Description", mDescription, ""

jb.EncodeName "EntryOrderId"
jb.EncodeValue mEntryOrderId

jb.EncodeNameAndValue "EntryReason", mEntryReason, ""

jb.EncodeName "Key"
jb.EncodeValue mKey

jb.EncodeNameAndValue "PreventUnprotectedPosition", mPreventUnprotectedPosition, False

jb.EncodeName "Size"
jb.EncodeValue mSize

jb.EncodeName "State"
jb.EncodeValue mState

jb.EncodeNameAndValue "StopLossOrderId", mStopLossOrderId, ""

jb.EncodeNameAndValue "StopReason", mStopReason, ""

jb.EncodeNameAndValue "TargetOrderId", mTargetOrderId, ""

jb.EncodeNameAndValue "TargetReason", mTargetReason, ""

'jb.EncodeName "GroupName"
'jb.EncodeValue mGroupName

jb.EndObject

ToJSON = jb.JSONString
End Function

'@================================================================================
' Helper Functions
'@================================================================================

Private Sub setDirty()
mIsDirty = True
End Sub


