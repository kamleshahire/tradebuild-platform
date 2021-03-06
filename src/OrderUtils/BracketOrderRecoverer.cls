VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "BracketOrderRecoverer"
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

Private Const ModuleName                            As String = "BracketOrderRecoverer"

'@================================================================================
' Member variables
'@================================================================================

Private mBracketOrder                               As BracketOrder

Private mPositionManager                            As PositionManager
Private mOrderSubmissionListener                    As IOrderSubmissionListener

Private mOrderContext                               As OrderContext
    
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

Friend Property Get Key() As String
Key = mBracketOrder.Key
End Property

Friend Property Get BracketOrder() As IBracketOrder
Set BracketOrder = mBracketOrder
End Property

'@================================================================================
' Methods
'@================================================================================

Friend Sub FinishRecovery()
Const ProcName As String = "FinishRecovery"
On Error GoTo Err

setUnrecoveredOrderAsCancelled mBracketOrder.EntryOrder
setUnrecoveredOrderAsCancelled mBracketOrder.StopLossOrder
setUnrecoveredOrderAsCancelled mBracketOrder.TargetOrder
setUnrecoveredOrderAsCancelled mBracketOrder.CloseoutOrder

mOrderContext.ActivateBracketOrder mBracketOrder

Dim lRecoverable As IRecoverable
Set lRecoverable = mBracketOrder
lRecoverable.FinishRecovery

gLog "Finished recovering bracket order", pMsgQualifier:=mBracketOrder.Key, pModName:=ModuleName, pProcName:=ProcName

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Friend Sub Initialise( _
                ByVal pPositionManager As PositionManager, _
                ByVal pOrderContext As OrderContext, _
                ByVal pKey As String)
Const ProcName As String = "Initialise"
On Error GoTo Err

gLog "Recreating bracket order", pMsgQualifier:=pKey, pModName:=ModuleName, pProcName:=ProcName

Set mBracketOrder = New BracketOrder

Set mPositionManager = pPositionManager
Set mOrderSubmissionListener = mPositionManager

Set mOrderContext = pOrderContext

mBracketOrder.Initialise pKey, _
                        mPositionManager.Name, _
                        mPositionManager.GroupName, _
                        mOrderContext, _
                        mPositionManager.ContractFuture.Value, _
                        mPositionManager.OrderSubmitter, _
                        mPositionManager.DataSource, _
                        mPositionManager.IsSimulated

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Friend Sub NotifyExecutionReport( _
                ByVal pExecutionReport As IExecutionReport)
Const ProcName As String = "NotifyExecutionReport"
On Error GoTo Err

mOrderSubmissionListener.NotifyExecutionReport pExecutionReport

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Friend Sub NotifyOrderReport( _
                ByVal pOrderReport As IOrderReport)
Const ProcName As String = "NotifyOrderReport"
On Error GoTo Err

If syncOrderToOrderReport(mBracketOrder.EntryOrder, pOrderReport) Then
ElseIf syncOrderToOrderReport(mBracketOrder.StopLossOrder, pOrderReport) Then
ElseIf syncOrderToOrderReport(mBracketOrder.TargetOrder, pOrderReport) Then
ElseIf syncOrderToOrderReport(mBracketOrder.CloseoutOrder, pOrderReport) Then
End If

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Friend Sub UpdateExecution( _
                ByVal pExec As IExecutionReport)
Const ProcName As String = "UpdateExecution"
On Error GoTo Err

mOrderSubmissionListener.NotifyExecutionReport pExec

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Friend Sub updateOrder(ByVal pOs As OrderSummary)
Const ProcName As String = "updateOrder"
On Error GoTo Err

Dim lRecoverable As IRecoverable

If orderIdIsForOrder(pOs.Id, mBracketOrder.EntryOrder) Then
    Set lRecoverable = mBracketOrder.EntryOrder
ElseIf orderIdIsForOrder(pOs.Id, mBracketOrder.StopLossOrder) Then
    Set lRecoverable = mBracketOrder.StopLossOrder
ElseIf orderIdIsForOrder(pOs.Id, mBracketOrder.TargetOrder) Then
    Set lRecoverable = mBracketOrder.TargetOrder
ElseIf orderIdIsForOrder(pOs.Id, mBracketOrder.CloseoutOrder) Then
    Set lRecoverable = mBracketOrder.CloseoutOrder
End If

lRecoverable.LoadRecoveryData pOs

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Friend Sub UpdateBracketOrder(ByVal ops As BracketOrderSummary)
Const ProcName As String = "UpdateBracketOrder"
On Error GoTo Err

Dim lRecoverable As IRecoverable

Set lRecoverable = mBracketOrder
lRecoverable.LoadRecoveryData ops

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

'@================================================================================
' Helper Functions
'@================================================================================

Private Function orderIdIsForOrder( _
                ByVal pId As String, _
                ByVal pOrder As IOrder) As Boolean
Const ProcName As String = "orderIdIsForOrder"
On Error GoTo Err

If pOrder Is Nothing Then Exit Function
orderIdIsForOrder = (pId = pOrder.Id)

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Private Sub setUnrecoveredOrderAsCancelled(ByVal pOrder As Order)
Const ProcName As String = "setUnrecoveredOrderAsCancelled"
On Error GoTo Err

If pOrder Is Nothing Then Exit Sub
If pOrder.NeedsRecovery Then
    gLog "Order has not been recovered - cancelling: broker id=" & pOrder.BrokerId, ProcName, ModuleName
    pOrder.Status = OrderStatusCancelled
Else
    Dim lRecoverable As IRecoverable
    Set lRecoverable = pOrder
    lRecoverable.FinishRecovery
End If

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Private Function syncOrderToOrderReport( _
                ByVal pOrder As IOrder, _
                ByVal pOrderReport As IOrderReport) As Boolean
Const ProcName As String = "syncOrderToOrderReport"
On Error GoTo Err

If Not orderIdIsForOrder(pOrderReport.Id, pOrder) Then Exit Function

pOrder.SyncToOrderReport pOrderReport
mPositionManager.OrderSubmitter.NotifyRecoveredOrder pOrder

If pOrder.Id <> mBracketOrder.EntryOrder.Id And pOrder.Status = OrderStatusSubmitted Then
    ' this order is not the entry order, but its status is Submitted. This means
    ' that the entry order must have received at least one fill.
    ' 23/2/15 So why do I set the entry order status to Filled?????
    mBracketOrder.EntryOrder.Status = OrderStatusFilled
End If

syncOrderToOrderReport = True

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

