VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ChartRegions"
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

Implements IEnumerable

'@================================================================================
' Events
'@================================================================================

''
' Raised when an Item is added to or removed from this
' <code>ChartRegions</code> object, and when the collection is cleared.
'
' @remarks
'   The following members of the <code>CollectionChangeTypes</code> enum may
'   occur in the <code>ChangeType</code> field of the
'   <code>CollectionChangedEvent</code> parameter:
' <blockquote>
'    <tt>CollItemAdded</tt><br />
'    <tt>CollItemRemoved</tt><br />
'    <tt>CollCollectionCleared</tt>
' </blockquote>
' @param ev
'   contains details of the change.
'
'@/
Event CollectionChanged( _
                ev As CollectionChangeEventData)

'@================================================================================
' Enums
'@================================================================================

'@================================================================================
' Types
'@================================================================================

Private Type RegionTableEntry
    Region              As ChartRegion
    PercentHeight       As Double
'    ActualHeight        As Long
    useAvailableSpace   As Boolean
End Type

'@================================================================================
' Constants
'@================================================================================

Private Const ModuleName                            As String = "ChartRegions"

'@================================================================================
' Member variables
'@================================================================================

Private mChartRef                                   As WeakReference
Private mPeriods                                    As Periods

Private mRegions()                                  As RegionTableEntry
Private mRegionsIndex                               As Long
Private mNumRegionsInUse                            As Long

Private mUpdateSequence                             As Long

Private mDefaultDataRegionStyle                     As ChartRegionStyle
Private mDefaultYAxisRegionStyle                    As ChartRegionStyle

Private mRegionHeightReductionFactor                As Double

Private mFinished                                   As Boolean

'@================================================================================
' Class Event Handlers
'@================================================================================

Private Sub Class_Initialize()
ReDim mRegions(3) As RegionTableEntry
mRegionsIndex = 0
mRegionHeightReductionFactor = 1
End Sub

'@================================================================================
' IEnumerable Interface Members
'@================================================================================

Private Property Get IEnumerable_Enumerator() As Enumerator
Set IEnumerable_Enumerator = getEnumerator
End Property

Private Function IEnumerable_NextItem(Item As Variant, cookie As Variant) As Boolean
If cookie = &H7FFFFFFF Then Exit Function
If IsEmpty(cookie) Then cookie = -1

Do
    cookie = cookie + 2
    If cookie > mRegionsIndex Then
        cookie = &H7FFFFFFF
        Exit Function
    End If
Loop Until (Not mRegions(cookie).Region Is Nothing)

Set Item = mRegions(cookie).Region

IEnumerable_NextItem = True
End Function

Private Sub IEnumerable_Remove(cookie As Variant)
Remove mRegions(cookie).Region
End Sub

Private Function IEnumerable_Skip(ByVal numToSkip As Long, cookie As Variant) As Boolean
Const ProcName As String = "IEnumerable_Skip"
On Error GoTo Err

Err.Raise ErrorCodes.ErrUnsupportedOperationException, , "Skip not supported"

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Private Property Get IEnumerable_UpdateSequence() As Long
IEnumerable_UpdateSequence = mUpdateSequence
End Property

'@================================================================================
' XXXX Event Handlers
'@================================================================================

'@================================================================================
' Properties
'@================================================================================

Public Property Get Count() As Long
If IsFinished Then Err.Raise ErrorCodes.ErrIllegalStateException, , "ChartRegions object is finished"

Count = mNumRegionsInUse
End Property

Friend Property Let DefaultDataRegionStyle( _
                ByVal Value As ChartRegionStyle)
Dim lregion As ChartRegion
Const ProcName As String = "DefaultDataRegionStyle"
On Error GoTo Err

If IsFinished Then Err.Raise ErrorCodes.ErrIllegalStateException, , "ChartRegions object is finished"

Set mDefaultDataRegionStyle = Value
For Each lregion In Me
    lregion.BaseStyle = mDefaultDataRegionStyle
Next

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

Friend Property Let DefaultYAxisRegionStyle( _
                ByVal Value As ChartRegionStyle)
Dim lregion As ChartRegion
Const ProcName As String = "DefaultYAxisRegionStyle"
On Error GoTo Err

If IsFinished Then Err.Raise ErrorCodes.ErrIllegalStateException, , "ChartRegions object is finished"

Set mDefaultYAxisRegionStyle = Value
For Each lregion In Me
    lregion.YAxisRegion.BaseStyle = mDefaultYAxisRegionStyle
Next

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

''
' Returns an <code>Enumerator</code> object that can be used to iterate through
' the members of the collection.
'
' @return
'   An <code>Enumerator</code> object.
'@/
Public Property Get Enumerator() As Enumerator
Const ProcName As String = "Enumerator"
On Error GoTo Err

If IsFinished Then Err.Raise ErrorCodes.ErrIllegalStateException, , "ChartRegions object is finished"

Set Enumerator = getEnumerator

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

Public Property Get Item(ByVal Name As String) As ChartRegion
Attribute Item.VB_UserMemId = 0
Attribute Item.VB_MemberFlags = "400"
Const ProcName As String = "Item"
On Error GoTo Err

If IsFinished Then Err.Raise ErrorCodes.ErrIllegalStateException, , "ChartRegions object is finished"

Set Item = findRegion(Name)

If Item Is Nothing Then Err.Raise ErrorCodes.ErrIllegalArgumentException, , "Item does not exist"

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

'@================================================================================
' Methods
'@================================================================================

Public Function Add( _
                Optional ByVal PercentHeight As Double = 100#, _
                Optional ByVal MinimumPercentHeight As Double, _
                Optional ByVal Style As ChartRegionStyle, _
                Optional ByVal YAxisStyle As ChartRegionStyle, _
                Optional ByVal Name As String) As ChartRegion

Dim YAxisRegion As ChartRegion
Dim Availableheight As Long
Dim lregion As ChartRegion


'
' NB: PercentHeight=100 means the region will use whatever space
' is available
'

Const ProcName As String = "Add"

On Error GoTo Err

If IsFinished Then Err.Raise ErrorCodes.ErrIllegalStateException, , "ChartRegions object is finished"

Availableheight = chartObj.Availableheight

If Name <> "" Then
    If Contains(Name) Then Err.Raise ErrorCodes.ErrIllegalStateException, , "Region " & Name & " already exists"
Else
    Name = GenerateGUIDString
End If

mRegionsIndex = mRegionsIndex + 1

Set lregion = New ChartRegion
lregion.handle = mRegionsIndex

lregion.Initialise Name, mPeriods, chartObj.CreateViewport(lregion, RegionTypeData), RegionTypeData

lregion.MinimumPercentHeight = MinimumPercentHeight
lregion.PercentHeight = PercentHeight

If Style Is Nothing Then
    gLogger.Log "Style applied", ProcName, ModuleName, , "none"
Else
    gLogger.Log "Style applied", ProcName, ModuleName, , Style.Name
End If
lregion.Style = Style

gLogger.Log "Base style applied", ProcName, ModuleName, , mDefaultDataRegionStyle.Name
lregion.BaseStyle = mDefaultDataRegionStyle

Set mRegions(mRegionsIndex).Region = lregion
If PercentHeight <> 100 Then
    mRegions(mRegionsIndex).PercentHeight = mRegionHeightReductionFactor * PercentHeight
Else
    mRegions(mRegionsIndex).useAvailableSpace = True
End If

mRegionsIndex = mRegionsIndex + 1
If mRegionsIndex > UBound(mRegions) Then
    ReDim Preserve mRegions(2 * (UBound(mRegions) + 1) - 1) As RegionTableEntry
End If

Set YAxisRegion = New ChartRegion
YAxisRegion.handle = mRegionsIndex

YAxisRegion.Initialise "", mPeriods, chartObj.CreateViewport(YAxisRegion, RegionTypeYAxis), RegionTypeYAxis
YAxisRegion.Bottom = 0
YAxisRegion.Top = 1
YAxisRegion.SetPeriodsInView 0, 99

YAxisRegion.Style = YAxisStyle
YAxisRegion.BaseStyle = mDefaultYAxisRegionStyle
lregion.YAxisRegion = YAxisRegion

Set mRegions(mRegionsIndex).Region = YAxisRegion

mNumRegionsInUse = mNumRegionsInUse + 1

If ResizeY(False) Then
    changed
    fireChange CollItemAdded, lregion
Else
    ' can't fit this all in! So remove the added region,
    Set lregion = Nothing
    Set mRegions(mRegionsIndex).Region = Nothing
    mRegions(mRegionsIndex).PercentHeight = 0
    mRegions(mRegionsIndex).useAvailableSpace = False
    mRegionsIndex = mRegionsIndex - 2
    mNumRegionsInUse = mNumRegionsInUse - 1
    Exit Function
End If

Set Add = lregion

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Function Contains(ByVal Name As String) As Boolean
Dim lregion As ChartRegion

Const ProcName As String = "Contains"

On Error GoTo Err

If IsFinished Then Err.Raise ErrorCodes.ErrIllegalStateException, , "ChartRegions object is finished"

Set lregion = findRegion(Name)
If Not lregion Is Nothing Then Contains = True

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName

End Function

Friend Sub Finish()
Set mChartRef = Nothing
mFinished = True
End Sub

Friend Sub Initialise( _
                ByVal pChart As Chart, _
                ByVal pPeriods As Periods)
Set mChartRef = CreateWeakReference(pChart)
Set mPeriods = pPeriods
End Sub

Friend Function IsFinished() As Boolean
IsFinished = mFinished
End Function

Friend Function ItemFromHandle(ByVal pHandle As Long) As ChartRegion
Const ProcName As String = "ItemFromHandle"
On Error GoTo Err

If IsFinished Then Err.Raise ErrorCodes.ErrIllegalStateException, , "ChartRegions object is finished"

Set ItemFromHandle = mRegions(pHandle).Region

If ItemFromHandle Is Nothing Then Err.Raise ErrorCodes.ErrIllegalArgumentException, , "Invalid Handle"

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName

End Function

Public Function NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4
Attribute NewEnum.VB_MemberFlags = "40"
Const ProcName As String = "NewEnum"

On Error GoTo Err

If IsFinished Then Err.Raise ErrorCodes.ErrIllegalStateException, , "ChartRegions object is finished"

Set NewEnum = getEnumerator

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Sub Remove( _
                ByVal pRegion As ChartRegion)
Const ProcName As String = "Remove"

On Error GoTo Err

If IsFinished Then Err.Raise ErrorCodes.ErrIllegalStateException, , "ChartRegions object is finished"

If pRegion.IsXAxisRegion Or pRegion.IsYAxisRegion Then Err.Raise ErrorCodes.ErrIllegalStateException, , "Cannot remove an axis region"

If mRegions(pRegion.handle).Region Is Nothing Then Err.Raise ErrorCodes.ErrIllegalStateException, , "Region has already been removed"

Set mRegions(pRegion.handle).Region = Nothing
Set mRegions(pRegion.handle + 1).Region = Nothing

mNumRegionsInUse = mNumRegionsInUse - 1

changed
fireChange CollItemRemoved, pRegion

' don't clear the region until after the CollectionChange event has been fired,
' in case the event listener needs some information from the region
pRegion.ClearRegion

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Friend Function ResizeRegion( _
                ByVal pRegion As ChartRegion, _
                ByVal vertChange As Long) As Boolean
Dim handle As Long
Dim newHeight As Long
Dim prevPercentHeight As Double
Dim Availableheight As Long

Const ProcName As String = "ResizeRegion"

On Error GoTo Err

If IsFinished Then Err.Raise ErrorCodes.ErrIllegalStateException, , "ChartRegions object is finished"

handle = pRegion.handle
Availableheight = chartObj.Availableheight

newHeight = pRegion.ActualHeight + vertChange
If newHeight < 0 Then newHeight = 0

' the region table indicates the requested percentage used by each region
' and the actual Height allocation. We need to work out the new percentage
' for the region to be resized.

prevPercentHeight = mRegions(handle).PercentHeight
mRegions(handle).PercentHeight = 100 * newHeight / Availableheight
If mRegions(handle).useAvailableSpace Then
    ' this is a 'use available space' region that's being resized. Now change
    ' it to use a specific percentage
    mRegions(handle).useAvailableSpace = False
    mRegions(handle).Region.PercentHeight = mRegions(handle).PercentHeight
End If

If ResizeY(True) Then
    ResizeRegion = True
Else
    ' the regions couldn't be resized so reset the region's percent Height
    mRegions(handle).PercentHeight = prevPercentHeight
End If

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName

End Function

Friend Function ResizeY( _
                ByVal userResizing As Boolean) As Boolean
'
' NB: PercentHeight=100 means the region will use whatever space
' is available
'
Dim i As Long
Dim aRegion As ChartRegion
Dim numAvailableSpaceRegions As Long
Dim totalMinimumPercents As Double
Dim nonFixedAvailableSpacePercent As Double
Dim availableSpacePercent As Double
Dim Availableheight As Long

Const ProcName As String = "ResizeY"

On Error GoTo Err

If IsFinished Then Err.Raise ErrorCodes.ErrIllegalStateException, , "ChartRegions object is finished"

availableSpacePercent = 100
nonFixedAvailableSpacePercent = 100
Availableheight = chartObj.Availableheight

For i = 1 To mRegionsIndex Step 2
    If Not mRegions(i).Region Is Nothing Then
        Set aRegion = mRegions(i).Region
        If Not mRegions(i).useAvailableSpace Then
            availableSpacePercent = availableSpacePercent - mRegions(i).PercentHeight
            nonFixedAvailableSpacePercent = nonFixedAvailableSpacePercent - mRegions(i).PercentHeight
        Else
            If aRegion.MinimumPercentHeight <> 0 Then
                availableSpacePercent = availableSpacePercent - aRegion.MinimumPercentHeight
            End If
            numAvailableSpaceRegions = numAvailableSpaceRegions + 1
        End If
    End If
Next

If availableSpacePercent < 0 And userResizing Then
    ResizeY = False
    Exit Function
End If

mRegionHeightReductionFactor = 1
Do While availableSpacePercent < 0 And mRegionHeightReductionFactor >= 0.0625
    availableSpacePercent = 100
    nonFixedAvailableSpacePercent = 100
    totalMinimumPercents = 0
    mRegionHeightReductionFactor = mRegionHeightReductionFactor - 0.0625
    For i = 1 To mRegionsIndex Step 2
        If Not mRegions(i).Region Is Nothing Then
            Set aRegion = mRegions(i).Region
            If Not mRegions(i).useAvailableSpace Then
                If aRegion.MinimumPercentHeight <> 0 Then
                    If mRegions(i).PercentHeight * mRegionHeightReductionFactor >= _
                        aRegion.MinimumPercentHeight _
                    Then
                        mRegions(i).PercentHeight = mRegions(i).PercentHeight * mRegionHeightReductionFactor
                    Else
                        mRegions(i).PercentHeight = aRegion.MinimumPercentHeight
                    End If
                    totalMinimumPercents = totalMinimumPercents + aRegion.MinimumPercentHeight
                Else
                    mRegions(i).PercentHeight = mRegions(i).PercentHeight * mRegionHeightReductionFactor
                End If
                availableSpacePercent = availableSpacePercent - mRegions(i).PercentHeight
                nonFixedAvailableSpacePercent = nonFixedAvailableSpacePercent - mRegions(i).PercentHeight
            Else
                If aRegion.MinimumPercentHeight <> 0 Then
                    availableSpacePercent = availableSpacePercent - aRegion.MinimumPercentHeight
                    totalMinimumPercents = totalMinimumPercents + aRegion.MinimumPercentHeight
                End If
            End If
        End If
    Next
    If totalMinimumPercents > 100 Then
        ' can't possibly fit this all in!
        ResizeY = False
        Exit Function
    End If
Loop

If numAvailableSpaceRegions = 0 Then
    ' we must adjust the percentages on the other regions so they
    ' total 100.
    For i = 1 To mRegionsIndex Step 2
        If Not mRegions(i).Region Is Nothing Then
            mRegions(i).PercentHeight = 100 * mRegions(i).PercentHeight / (100 - nonFixedAvailableSpacePercent)
        End If
    Next
End If

' first set Heights for fixed Height regions
For i = 1 To mRegionsIndex Step 2
    If Not mRegions(i).Region Is Nothing Then
        If Not mRegions(i).useAvailableSpace Then
            mRegions(i).Region.ActualHeight = mRegions(i).PercentHeight * Availableheight / 100
            Debug.Assert mRegions(i).Region.ActualHeight >= 0
        End If
    End If
Next

' now set Heights for 'available space' regions with a minimum Height
' that needs to be respected
For i = 1 To mRegionsIndex Step 2
    If Not mRegions(i).Region Is Nothing Then
        Set aRegion = mRegions(i).Region
        If mRegions(i).useAvailableSpace Then
            mRegions(i).Region.ActualHeight = 0
            If aRegion.MinimumPercentHeight <> 0 Then
                If (nonFixedAvailableSpacePercent / numAvailableSpaceRegions) < aRegion.MinimumPercentHeight Then
                    mRegions(i).Region.ActualHeight = aRegion.MinimumPercentHeight * Availableheight / 100
                    Debug.Assert mRegions(i).Region.ActualHeight >= 0
                    nonFixedAvailableSpacePercent = nonFixedAvailableSpacePercent - aRegion.MinimumPercentHeight
                    numAvailableSpaceRegions = numAvailableSpaceRegions - 1
                End If
            End If
        End If
    End If
Next

' finally set Heights for all other 'available space' regions
For i = 1 To mRegionsIndex Step 2
    If Not mRegions(i).Region Is Nothing Then
        If mRegions(i).useAvailableSpace And _
            mRegions(i).Region.ActualHeight = 0 _
        Then
            mRegions(i).Region.ActualHeight = (nonFixedAvailableSpacePercent / numAvailableSpaceRegions) * Availableheight / 100
            Debug.Assert mRegions(i).Region.ActualHeight >= 0
        End If
    End If
Next

ResizeY = True

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

'@================================================================================
' Helper Functions
'@================================================================================

Private Sub changed()
mUpdateSequence = mUpdateSequence + 1
End Sub

Private Function chartObj() As Chart
Const ProcName As String = "chartObj"

On Error GoTo Err

Set chartObj = mChartRef.Target

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Private Sub fireChange( _
                ByVal changeType As CollectionChangeTypes, _
                ByVal affectedItem As Variant)
Dim ev As CollectionChangeEventData
Const ProcName As String = "fireChange"

On Error GoTo Err

Set ev.Source = Me
ev.changeType = changeType
gSetVariant ev.affectedItem, affectedItem
RaiseEvent CollectionChanged(ev)

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Private Function getEnumerator() As Enumerator
Const ProcName As String = "getEnumerator"

On Error GoTo Err

Set getEnumerator = CreateEnumerator(Me)

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Private Function findRegion( _
                ByVal Name As String) As ChartRegion
Dim en As Enumerator
Dim lregion As ChartRegion

Const ProcName As String = "findRegion"

On Error GoTo Err

Name = UCase$(Name)

Set en = getEnumerator

Do While en.MoveNext
    Set lregion = en.Current
    If UCase$(lregion.Name) = Name Then
        Set findRegion = lregion
        Exit Do
    End If
Loop

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function
