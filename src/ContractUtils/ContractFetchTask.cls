VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ContractFetchTask"
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

Implements IContractFetchListener
Implements ITask

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

Private Const ModuleName                            As String = "ContractFetchTask"

'@================================================================================
' Member variables
'@================================================================================

Private mPrimaryContractStore                       As IContractStore
Private mSecondaryContractStore                     As IContractStore

Private mContractSpec                               As IContractSpecifier

Private mTaskContext                                As TaskContext

Private mUsedSecondaryContractStore                 As Boolean

Private WithEvents mContractsFutureBuilder          As FutureBuilder
Attribute mContractsFutureBuilder.VB_VarHelpID = -1
Private WithEvents mContractFutureBuilder           As FutureBuilder
Attribute mContractFutureBuilder.VB_VarHelpID = -1

Private mSingleContractOnly                         As Boolean

Private mListener                                   As IContractFetchListener

Private mCookie                                     As Variant

Private mFetchFuture                                As IFuture

Private mContractsBuilder                           As New ContractsBuilder

'@================================================================================
' Class Event Handlers
'@================================================================================

'@================================================================================
' IContractFetchListener Interface Members
'@================================================================================

Private Sub IContractFetchListener_FetchCancelled(ByVal pCookie As Variant)
Const ProcName As String = "IContractFetchListener_FetchCancelled"
On Error GoTo Err

If Not futureIsPending Then Exit Sub

If mSingleContractOnly Then
    mContractFutureBuilder.Cancel
Else
    mContractsFutureBuilder.Cancel
End If

If Not mListener Is Nothing Then mListener.FetchCancelled pCookie
mTaskContext.Finish Empty, False

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Private Sub IContractFetchListener_FetchCompleted(ByVal pCookie As Variant)
Const ProcName As String = "IContractFetchListener_FetchCompleted"
On Error GoTo Err

If Not futureIsPending Then Exit Sub

Dim lContracts As IContracts
Set lContracts = mFetchFuture.Value
If lContracts.Count = 0 And Not mUsedSecondaryContractStore Then If trySecondaryContractSP Then Exit Sub

If mSingleContractOnly Then
    If lContracts.Count = 0 Then
        mContractFutureBuilder.Fail ErrorCodes.ErrIllegalArgumentException, "No such contract", ""
    Else
        mContractFutureBuilder.Value = lContracts.ItemAtIndex(1)
        mContractFutureBuilder.Complete
    End If
Else
    mContractsFutureBuilder.Value = mContractsBuilder.Contracts
    mContractsFutureBuilder.Complete
End If

If Not mListener Is Nothing Then mListener.FetchCompleted pCookie
mTaskContext.Finish Empty, False

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Private Sub IContractFetchListener_FetchFailed(ByVal pCookie As Variant, ByVal pErrorCode As Long, ByVal pErrorMessage As String, ByVal pErrorSource As String)
Const ProcName As String = "IContractFetchListener_FetchFailed"
On Error GoTo Err

If Not futureIsPending Then Exit Sub

If mSingleContractOnly Then
    mContractFutureBuilder.Fail pErrorCode, pErrorMessage, pErrorSource
Else
    mContractsFutureBuilder.Fail pErrorCode, pErrorMessage, pErrorSource
End If

If Not mListener Is Nothing Then mListener.FetchFailed pCookie, pErrorCode, pErrorMessage, pErrorSource
mTaskContext.Finish Empty, False

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Private Sub IContractFetchListener_NotifyContract(ByVal pCookie As Variant, ByVal pContract As IContract)
Const ProcName As String = "IContractFetchListener_NotifyContract"
On Error GoTo Err

If Not futureIsPending Then Exit Sub

If mSingleContractOnly Then
    If mContractsBuilder.Contracts.Count = 1 Then
        mContractFutureBuilder.Fail ErrorCodes.ErrIllegalArgumentException, "Contract is not uniquely specified", ""
        mFetchFuture.Cancel
        mTaskContext.Finish Empty, False
        Exit Sub
    End If
End If

mContractsBuilder.Add pContract

If Not mListener Is Nothing Then mListener.NotifyContract pCookie, pContract

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

'@================================================================================
' ITask Interface Members
'@================================================================================

Private Sub ITask_Cancel()

End Sub

Private Sub ITask_Run()
Const ProcName As String = "ITask_Run"
On Error GoTo Err

Dim lContractStore As IContractStore
Set lContractStore = mPrimaryContractStore
If lContractStore Is Nothing Then
    Set lContractStore = mSecondaryContractStore
    mUsedSecondaryContractStore = True
End If

Set mFetchFuture = lContractStore.FetchContracts(mContractSpec, Me, mCookie)
mTaskContext.suspend -1

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Private Property Let ITask_TaskContext(ByVal Value As TaskContext)
Const ProcName As String = "ITask_TaskContext"
On Error GoTo Err

Set mTaskContext = Value

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

Private Property Get ITask_TaskName() As String
Const ProcName As String = "ITask_TaskName"
On Error GoTo Err

ITask_TaskName = mTaskContext.Name

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

'@================================================================================
' mContractFutureBuilder Handlers
'@================================================================================

Private Sub mContractFutureBuilder_Cancelled(ev As CancelledEventData)
Const ProcName As String = "mContractFutureBuilder_Cancelled"
On Error GoTo Err

If Not mFetchFuture Is Nothing Then mFetchFuture.Cancel
If Not mListener Is Nothing Then mListener.FetchCancelled mContractFutureBuilder.Cookie
mTaskContext.Finish Empty, True

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName
End Sub

'@================================================================================
' mContractsFutureBuilder Handlers
'@================================================================================

Private Sub mContractsFutureBuilder_Cancelled(ev As CancelledEventData)
Const ProcName As String = "mContractsFutureBuilder_Cancelled"
On Error GoTo Err

If Not mFetchFuture Is Nothing Then mFetchFuture.Cancel
If Not mListener Is Nothing Then mListener.FetchCancelled mContractsFutureBuilder.Cookie
mTaskContext.Finish Empty, True

Exit Sub

Err:
gNotifyUnhandledError ProcName, ModuleName
End Sub

'@================================================================================
' Properties
'@================================================================================

Friend Property Get ContractFuture() As IFuture
Const ProcName As String = "ContractFuture"
On Error GoTo Err

Set ContractFuture = mContractFutureBuilder.Future

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

Friend Property Get ContractsFuture() As IFuture
Const ProcName As String = "ContractsFuture"
On Error GoTo Err

Set ContractsFuture = mContractsFutureBuilder.Future

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

'@================================================================================
' Methods
'@================================================================================

Friend Sub Initialise( _
                ByVal pContractSpec As IContractSpecifier, _
                ByVal pPrimaryContractStore As IContractStore, _
                ByVal pSecondaryContractStore As IContractStore, _
                ByVal pCookie As Variant, _
                ByVal pListener As IContractFetchListener, _
                ByVal pSingleContractOnly As Boolean)
Const ProcName As String = "Initialise"
On Error GoTo Err

Set mContractSpec = pContractSpec
Set mPrimaryContractStore = pPrimaryContractStore
Set mSecondaryContractStore = pSecondaryContractStore

gSetVariant mCookie, pCookie

Set mListener = pListener

mSingleContractOnly = pSingleContractOnly
If mSingleContractOnly Then
    Set mContractFutureBuilder = New FutureBuilder
    mContractFutureBuilder.Cookie = mCookie
Else
    Set mContractsFutureBuilder = New FutureBuilder
    mContractsFutureBuilder.Cookie = mCookie
End If

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

'@================================================================================
' Helper Functions
'@================================================================================

Private Function futureIsPending() As Boolean
Const ProcName As String = "futureIsPending"
On Error GoTo Err

If mSingleContractOnly Then
    futureIsPending = mContractFutureBuilder.Future.IsPending
Else
    futureIsPending = mContractsFutureBuilder.Future.IsPending
End If

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Private Function trySecondaryContractSP() As Boolean
Const ProcName As String = "trySecondaryContractSP"
On Error GoTo Err

mUsedSecondaryContractStore = True
If mSecondaryContractStore Is Nothing Then
    trySecondaryContractSP = False
Else
    Set mFetchFuture = mSecondaryContractStore.FetchContracts(mContractSpec, Me, mCookie)
    trySecondaryContractSP = True
End If

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function




