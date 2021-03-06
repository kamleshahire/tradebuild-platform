VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Contracts"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

'@================================================================================
' Description
'@================================================================================
'
'
'@================================================================================
' Amendment history
'@================================================================================
'
'
'
'

'@================================================================================
' Interfaces
'@================================================================================

Implements IContracts
Implements IStringable

'@================================================================================
' Events
'@================================================================================

Event CollectionChanged( _
                ev As CollectionChangeEventData)

'@================================================================================
' Constants
'@================================================================================

Private Const ModuleName                As String = "Contracts"

'@================================================================================
' Enums
'@================================================================================

'@================================================================================
' Types
'@================================================================================

'@================================================================================
' Member variables
'@================================================================================

Private mContracts                      As SortedDictionary

Private mChangeListeners                As New Listeners

Private mSortKeys()                     As ContractSortKeyIds

'@================================================================================
' Class Event Handlers
'@================================================================================

Private Sub Class_Initialize()
Set mContracts = CreateSortedDictionary(KeyTypeComparable)

ReDim mSortKeys(7) As ContractSortKeyIds
mSortKeys(0) = ContractSortKeySecType
mSortKeys(1) = ContractSortKeySymbol
mSortKeys(2) = ContractSortKeyMultiplier
mSortKeys(3) = ContractSortKeyExchange
mSortKeys(4) = ContractSortKeyCurrency
mSortKeys(5) = ContractSortKeyExpiry
mSortKeys(6) = ContractSortKeyStrike
mSortKeys(7) = ContractSortKeyRight

End Sub

'@================================================================================
' IContracts Interface Members
'@================================================================================

Private Sub IContracts_AddCollectionChangeListener(ByVal pListener As ICollectionChangeListener)
Const ProcName As String = "IContracts_AddCollectionChangeListener"
On Error GoTo Err

AddCollectionChangeListener pListener

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Private Property Get IContracts_Count() As Long
Const ProcName As String = "IContracts_Count"
On Error GoTo Err

IContracts_Count = Count

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

Private Property Get IContracts_Enumerator() As Enumerator
Const ProcName As String = "IContracts_Enumerator"
On Error GoTo Err

Set IContracts_Enumerator = Enumerator

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

Private Function IContracts_Item(ByVal pKey As IContractSpecifier) As IContract
Const ProcName As String = "IContracts_Item"
On Error GoTo Err

Set IContracts_Item = Item(pKey)

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Private Function IContracts_ItemAtIndex(ByVal pIndex As Long) As IContract
Const ProcName As String = "IContracts_ItemAtIndex"
On Error GoTo Err

Set IContracts_ItemAtIndex = ItemAtIndex(pIndex)

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Private Function IContracts_NewEnum() As stdole.IUnknown
Set IContracts_NewEnum = NewEnum
End Function

Private Sub IContracts_RemoveCollectionChangeListener(ByVal pListener As ICollectionChangeListener)
Const ProcName As String = "IContracts_RemoveCollectionChangeListener"
On Error GoTo Err

RemoveCollectionChangeListener pListener

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Private Property Let IContracts_SortKeys(Value() As ContractSortKeyIds)
setSortKeys Value
End Property

Private Property Get IContracts_SortKeys() As ContractSortKeyIds()
IContracts_SortKeys = SortKeys
End Property

Private Function IContracts_ToString() As String
Const ProcName As String = "IContracts_ToString"
On Error GoTo Err

IContracts_ToString = ToString

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

'@================================================================================
' IStringable Interface Members
'@================================================================================

Private Function IStringable_ToString() As String
IStringable_ToString = ToString
End Function

'@================================================================================
' xxxx Event Handlers
'@================================================================================

'@================================================================================
' Properties
'@================================================================================

Public Property Get Count() As Long
Const ProcName As String = "Count"
On Error GoTo Err

Count = mContracts.Count

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

Public Property Get Enumerator() As Enumerator
Set Enumerator = mContracts.Enumerator
End Property

Public Property Let SortKeys( _
                ByRef Value() As ContractSortKeyIds)
Const ProcName As String = "SortKeys"
On Error GoTo Err

setSortKeys Value

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property
                
Public Property Get SortKeys() As ContractSortKeyIds()
SortKeys = mSortKeys
End Property

'@================================================================================
' Methods
'@================================================================================

Friend Sub Add(ByVal pContract As IContract)
Const ProcName As String = "Add"
On Error GoTo Err

AddContract mContracts, pContract
fireCollectionChange CollItemAdded, pContract

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Public Sub AddCollectionChangeListener( _
                ByVal pListener As ICollectionChangeListener)
Const ProcName As String = "AddCollectionChangeListener"
On Error GoTo Err

mChangeListeners.Add pListener

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Public Function Item(ByVal pKey As IContractSpecifier) As IContract
Const ProcName As String = "Item"
On Error GoTo Err

Set Item = mContracts.Item(createComparable(pKey))

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Function ItemAtIndex(ByVal pIndex As Long) As IContract
Const ProcName As String = "ItemAtIndex"
On Error GoTo Err

AssertArgument pIndex > 0 And pIndex <= mContracts.Count, "Invalid index"

Dim en As Enumerator
Set en = Enumerator

Dim i As Long
Do While en.MoveNext
    i = i + 1
    If i = pIndex Then
        Set ItemAtIndex = en.Current
        Exit Function
    End If
Loop

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Function NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4
Attribute NewEnum.VB_MemberFlags = "40"
Set NewEnum = mContracts.Enumerator
End Function

Public Sub RemoveCollectionChangeListener( _
                ByVal pListener As ICollectionChangeListener)
Const ProcName As String = "RemoveCollectionChangeListener"
On Error GoTo Err

mChangeListeners.Remove pListener

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Public Function ToString() As String
Const ProcName As String = "ToString"
On Error GoTo Err


Dim en As Enumerator
Set en = Enumerator
Do While en.MoveNext
    Dim lContract As IContract
    Set lContract = en.Current
    ToString = ToString & lContract.Specifier.ToString & vbCrLf
Loop


Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

'@================================================================================
' Helper Functions
'@================================================================================

Private Sub AddContract(ByVal pContracts As SortedDictionary, ByVal pContract As IContract)
Const ProcName As String = "addContract"
On Error GoTo Err

pContracts.Add pContract, createComparable(pContract.Specifier)

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Private Function createComparable(ByVal pContractSpec As IContractSpecifier) As ContractComparable
Const ProcName As String = "createComparable"
On Error GoTo Err

Set createComparable = New ContractComparable
createComparable.Initialise pContractSpec, mSortKeys

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Private Sub fireCollectionChange( _
                ByVal changeType As CollectionChangeTypes, _
                ByVal affectedObject As IContract)
Const ProcName As String = "fireCollectionChange"
On Error GoTo Err

Dim ev As CollectionChangeEventData
Set ev.Source = Me
ev.changeType = changeType
Set ev.AffectedItem = affectedObject

Static sInit As Boolean
Static sCurrentListeners() As Object
Static sSomeListeners As Boolean

If Not sInit Or Not mChangeListeners.Valid Then
    sInit = True
    sSomeListeners = mChangeListeners.GetCurrentListeners(sCurrentListeners)
End If
If sSomeListeners Then
    Dim lListener As ICollectionChangeListener
    Dim i As Long
    For i = 0 To UBound(sCurrentListeners)
        Set lListener = sCurrentListeners(i)
        lListener.Change ev
    Next
End If
RaiseEvent CollectionChanged(ev)

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Private Sub setSortKeys( _
                ByRef Value() As ContractSortKeyIds)
Const ProcName As String = "setSortKeys"
On Error GoTo Err

If sortKeysEqual(mSortKeys, Value) Then Exit Sub

If UBound(Value) < 0 Then
    ReDim mSortKeys(0) As ContractSortKeyIds
    mSortKeys(0) = ContractSortKeyNone
Else
    mSortKeys = Value
End If

Dim lNewContracts As SortedDictionary
Set lNewContracts = CreateSortedDictionary(KeyTypeComparable)

Dim en As Enumerator
Set en = Enumerator
Do While en.MoveNext
    AddContract lNewContracts, en.Current
Loop

Set mContracts = lNewContracts

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub
                
Private Function sortKeysEqual( _
                ByRef pKeys1() As ContractSortKeyIds, _
                ByRef pKeys2() As ContractSortKeyIds) As Boolean
Const ProcName As String = "sortKeysEqual"
On Error GoTo Err

If UBound(pKeys1) < 0 And UBound(pKeys2) < 0 Then
    sortKeysEqual = True
ElseIf UBound(pKeys1) <> UBound(pKeys2) Then
    sortKeysEqual = False
Else
    sortKeysEqual = True
    Dim i As Long
    For i = 0 To UBound(pKeys1)
        If pKeys1(i) <> pKeys2(i) Then
            sortKeysEqual = False
            Exit For
        End If
    Next
End If

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function
