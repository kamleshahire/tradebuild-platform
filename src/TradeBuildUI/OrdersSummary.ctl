VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Object = "{5E9E78A0-531B-11CF-91F6-C2863C385E30}#1.0#0"; "MSFLXGRD.OCX"
Begin VB.UserControl OrdersSummary 
   ClientHeight    =   4245
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   12810
   ScaleHeight     =   4245
   ScaleWidth      =   12810
   Begin VB.TextBox EditText 
      Height          =   285
      Left            =   11160
      TabIndex        =   0
      Text            =   "Text1"
      Top             =   2160
      Visible         =   0   'False
      Width           =   975
   End
   Begin MSComctlLib.ImageList OrderPlexImageList 
      Left            =   11880
      Top             =   2760
      _ExtentX        =   1005
      _ExtentY        =   1005
      BackColor       =   -2147483643
      ImageWidth      =   32
      ImageHeight     =   32
      MaskColor       =   12632256
      _Version        =   393216
      BeginProperty Images {2C247F25-8591-11D1-B16A-00C0F0283628} 
         NumListImages   =   2
         BeginProperty ListImage1 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "OrdersSummary.ctx":0000
            Key             =   "Expand"
         EndProperty
         BeginProperty ListImage2 {2C247F27-8591-11D1-B16A-00C0F0283628} 
            Picture         =   "OrdersSummary.ctx":0452
            Key             =   "Contract"
         EndProperty
      EndProperty
   End
   Begin MSFlexGridLib.MSFlexGrid OrderPlexGrid 
      Height          =   3900
      Left            =   0
      TabIndex        =   1
      Top             =   0
      Width           =   12495
      _ExtentX        =   22040
      _ExtentY        =   6879
      _Version        =   393216
      Rows            =   0
      Cols            =   11
      FixedRows       =   0
      FixedCols       =   0
      BackColorBkg    =   -2147483643
      GridColorFixed  =   12632256
      MergeCells      =   2
      BorderStyle     =   0
      Appearance      =   0
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
   End
End
Attribute VB_Name = "OrdersSummary"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

'================================================================================
' Description
'================================================================================
'
'
'================================================================================
' Amendment history
'================================================================================
'
'
'
'

'================================================================================
' Interfaces
'================================================================================

Implements TradeBuild.ChangeListener
Implements TradeBuild.CollectionChangeListener
Implements TradeBuild.ProfitListener

'================================================================================
' Events
'================================================================================

Event Click()
Event SelectionChanged()
                
'================================================================================
' Constants
'================================================================================

' Percentage widths of the Open Orders columns
Private Const OpenOrdersOrderIDWidth = 9
Private Const OpenOrdersStatusWidth = 12
Private Const OpenOrdersActionWidth = 7
Private Const OpenOrdersQuantityWidth = 8
Private Const OpenOrdersSymbolWidth = 8
Private Const OpenOrdersOrdertypeWidth = 10
Private Const OpenOrdersPriceWidth = 10
Private Const OpenOrdersAuxPriceWidth = 10
Private Const OpenOrdersParentIDWidth = 9
Private Const OpenOrdersOCAGroupWidth = 9

' Percentage widths of the Open Orders columns
Private Const ExecutionsExecIdWidth = 25
Private Const ExecutionsOrderIDWidth = 10
Private Const ExecutionsActionWidth = 8
Private Const ExecutionsQuantityWidth = 8
Private Const ExecutionsSymbolWidth = 8
Private Const ExecutionsPriceWidth = 10
Private Const ExecutionsTimeWidth = 23

Private Const StandardFormHeight = 7230
Private Const ExtendedFormHeight = 9750

Private Const RowDataOrderPlexBase As Long = &H100
Private Const RowDataPositionManagerBase As Long = &H1000000

'================================================================================
' Enums
'================================================================================

Private Enum OPGridColumns
    symbol
    ExpandIndicator
    OtherColumns    ' keep this entry last
End Enum

Private Enum OPGridOrderPlexColumns
    creationTime = OPGridColumns.OtherColumns
    size
    profit
    MaxProfit
    drawdown
    currencyCode
End Enum

Private Enum OPGridPositionColumns
    exchange = OPGridColumns.OtherColumns
    size
    profit
    MaxProfit
    drawdown
    currencyCode
End Enum

Private Enum OPGridOrderColumns
    typeInPlex = OPGridColumns.OtherColumns
    size
    averagePrice
    Status
    action
    quantityRemaining
    orderType
    price
    auxPrice
    LastFillTime
    lastFillPrice
    id
    VendorId
End Enum

Private Enum OPGridColumnWidths
    ExpandIndicatorWidth = 3
    SymbolWidth = 15
End Enum

Private Enum OPGridOrderPlexColumnWidths
    CreationTimeWidth = 17
    SizeWidth = 5
    ProfitWidth = 8
    MaxProfitWidth = 8
    DrawdownWidth = 8
    CurrencyCodeWidth = 3
End Enum

Private Enum OPGridPositionColumnWidths
    ExchangeWidth = 9
    SizeWidth = 5
    ProfitWidth = 8
    MaxProfitWidth = 8
    DrawdownWidth = 8
    CurrencyCodeWidth = 5
End Enum

Private Enum OPGridOrderColumnWidths
    TypeInPlexWidth = 9
    SizeWidth = 5
    AveragePriceWidth = 9
    StatusWidth = 15
    ActionWidth = 5
    QuantityWidth = 7
    OrderTypeWidth = 7
    PriceWidth = 9
    AuxPriceWidth = 9
    LastFillTimeWidth = 17
    LastFillPriceWidth = 9
    IdWidth = 10
    VendorIdWidth = 10
End Enum

'================================================================================
' Types
'================================================================================

Private Type OrderPlexGridMappingEntry
    op                  As TradeBuild.orderPlex
    
    ' indicates whether this entry in the grid is expanded
    isExpanded          As Boolean
    
    ' index of first line in OrdersGrid relating to this entry
    gridIndex           As Long
                                
    ' offset from gridIndex of line in OrdersGrid relating to
    ' the corresponding order: -1 means  it's not in the grid
    entryGridOffset      As Long
    stopGridOffset       As Long
    targetGridOffset     As Long
    closeoutGridOffset   As Long
    
End Type

Private Type PositionManagerGridMappingEntry
    pm                  As TradeBuild.PositionManager
    
    ' indicates whether this entry in the grid is expanded
    isExpanded          As Boolean
    
    ' index of first line in OrdersGrid relating to this entry
    gridIndex           As Long
                                
End Type

'================================================================================
' Member variables
'================================================================================

Private mSelectedOrderPlexGridRow As Long
Private mSelectedOrderPlex As TradeBuild.orderPlex
Private mSelectedOrderIndex  As Long

Private mOrdersCol As Collection

Private mOrderPlexGridMappingTable() As OrderPlexGridMappingEntry
Private mMaxOrderPlexGridMappingTableIndex As Long

Private mPositionManagerGridMappingTable() As PositionManagerGridMappingEntry
Private mMaxPositionManagerGridMappingTableIndex As Long

' the index of the first entry in the order plex frid that relates to
' order plexes (rather than header rows, currency totals etc)
Private mFirstOrderPlexGridRowIndex As Long

Private mLetterWidth As Single
Private mDigitWidth As Single

Private mMonitoredWorkspaces As Collection

'================================================================================
' User Control Event Handlers
'================================================================================

Private Sub UserControl_Initialize()
Dim widthString As String

Set mMonitoredWorkspaces = New Collection

widthString = "ABCDEFGH IJKLMNOP QRST UVWX YZ"
mLetterWidth = UserControl.TextWidth(widthString) / Len(widthString)
widthString = ".0123456789"
mDigitWidth = UserControl.TextWidth(widthString) / Len(widthString)

setupOrderPlexGrid

ReDim mOrderPlexGridMappingTable(50) As OrderPlexGridMappingEntry
mMaxOrderPlexGridMappingTableIndex = -1

ReDim mPositionManagerGridMappingTable(20) As PositionManagerGridMappingEntry
mMaxPositionManagerGridMappingTableIndex = -1

End Sub

Private Sub UserControl_Resize()
OrderPlexGrid.Width = UserControl.Width
OrderPlexGrid.Height = UserControl.Height
End Sub

Private Sub UserControl_Terminate()
Debug.Print "OrdersSummary control terminated"
End Sub

'================================================================================
' ChangeListener Interface Members
'================================================================================

Private Sub ChangeListener_Change(ev As TradeBuild.ChangeEvent)
If TypeOf ev.Source Is TradeBuild.orderPlex Then
    Dim opChangeType As TradeBuild.OrderPlexChangeTypes
    Dim op As TradeBuild.orderPlex
    Dim opIndex As Long
    
    Set op = ev.Source
    
    opIndex = findOrderPlexTableIndex(op)
    
    With mOrderPlexGridMappingTable(opIndex)
    
        opChangeType = ev.changeType
        
        Select Case opChangeType
        Case OrderPlexChangeTypes.OrderPlexCreated
        
        Case OrderPlexChangeTypes.OrderPlexCompleted
            If op.size = 0 Then op.removeChangeListener Me
        Case OrderPlexChangeTypes.OrderPlexSelfCancelled
            If op.size = 0 Then op.removeChangeListener Me
        Case OrderPlexChangeTypes.OrderPlexEntryOrderChanged
            displayOrderValuesInOrderPlexGrid .gridIndex + .entryGridOffset, op.entryOrder
        Case OrderPlexChangeTypes.OrderPlexStopOrderChanged
            displayOrderValuesInOrderPlexGrid .gridIndex + .stopGridOffset, op.stopOrder
        Case OrderPlexChangeTypes.OrderPlexTargetOrderChanged
            displayOrderValuesInOrderPlexGrid .gridIndex + .targetGridOffset, op.targetOrder
        Case OrderPlexChangeTypes.OrderPlexCloseoutOrderCreated
            If .targetGridOffset >= 0 Then
                .closeoutGridOffset = .targetGridOffset + 1
            ElseIf .stopGridOffset >= 0 Then
                .closeoutGridOffset = .stopGridOffset + 1
            ElseIf .entryGridOffset >= 0 Then
                .closeoutGridOffset = .entryGridOffset + 1
            Else
                .closeoutGridOffset = 1
            End If
            
            addOrderEntryToOrderPlexGrid .gridIndex + .closeoutGridOffset, _
                                    .op.Contract.specifier.symbol, _
                                    op.closeoutOrder, _
                                    opIndex, _
                                    "Closeout"
        Case OrderPlexChangeTypes.OrderPlexCloseoutOrderChanged
            displayOrderValuesInOrderPlexGrid .gridIndex + .targetGridOffset, _
                                                op.closeoutOrder
        Case OrderPlexChangeTypes.OrderPlexProfitThresholdExceeded
    
        Case OrderPlexChangeTypes.OrderPlexLossThresholdExceeded
    
        Case OrderPlexChangeTypes.OrderPlexDrawdownThresholdExceeded
    
        Case OrderPlexChangeTypes.OrderPlexSizeChanged
            OrderPlexGrid.TextMatrix(.gridIndex, OPGridOrderPlexColumns.size) = op.size
        Case OrderPlexChangeTypes.OrderPlexStateChanged
            If op.State <> OrderPlexStateCodes.Created And _
                op.State <> OrderPlexStateCodes.Submitted _
            Then
                ' the order plex is now in a state where it can't be modified. If it's
                ' the currently selected order plex, make it not so.
                If op Is mSelectedOrderPlex Then
                    invertEntryColors mSelectedOrderPlexGridRow
                    mSelectedOrderPlexGridRow = -1
                    Set mSelectedOrderPlex = Nothing
                    RaiseEvent SelectionChanged
                End If
            End If
        End Select
    End With
ElseIf TypeOf ev.Source Is TradeBuild.PositionManager Then
    Dim pmChangeType As TradeBuild.PositionManagerChangeTypes
    Dim pm As TradeBuild.PositionManager
    Dim pmIndex As Long
    
    Set pm = ev.Source
    
    pmIndex = findPositionManagerTableIndex(pm)
    
    With mPositionManagerGridMappingTable(pmIndex)
    
        pmChangeType = ev.changeType
        
        Select Case pmChangeType
        Case PositionManagerChangeTypes.PositionSizeChanged
            OrderPlexGrid.TextMatrix(.gridIndex, OPGridPositionColumns.size) = pm.positionSize
        End Select
    End With
End If
End Sub

'================================================================================
' CollectionChangeListener Interface Members
'================================================================================

Private Sub CollectionChangeListener_Change(ev As TradeBuild.CollectionChangeEvent)
If TypeOf ev.affectedObject Is TradeBuild.orderPlex Then
    Dim op As TradeBuild.orderPlex
    Set op = ev.affectedObject
    
    Select Case ev.changeType
    Case CollItemAdded
        op.addChangeListener Me
        op.addProfitListener Me
    Case CollItemRemoved
        op.removeChangeListener Me
        op.removeProfitListener Me
    End Select
ElseIf TypeOf ev.affectedObject Is TradeBuild.ticker Then
    Dim lTicker As TradeBuild.ticker
    Set lTicker = ev.affectedObject
    
    Select Case ev.changeType
    Case CollItemAdded
        lTicker.PositionManager.addChangeListener Me
        lTicker.PositionManager.addProfitListener Me
    Case CollItemRemoved
        lTicker.PositionManager.removeChangeListener Me
        lTicker.PositionManager.removeProfitListener Me
    End Select
End If
End Sub

'================================================================================
' ProfitListener Interface Members
'================================================================================

Private Sub ProfitListener_profitAmount(ev As TradeBuild.ProfitEvent)
Dim rowIndex As Long

If TypeOf ev.Source Is TradeBuild.orderPlex Then
    Dim opProfitType As TradeBuild.ProfitTypes
    Dim op As TradeBuild.orderPlex
    Dim opIndex As Long
    
    Set op = ev.Source
    
    opIndex = findOrderPlexTableIndex(op)
    rowIndex = mOrderPlexGridMappingTable(opIndex).gridIndex
    opProfitType = ev.profitType
    
    Select Case opProfitType
    Case TradeBuild.ProfitTypes.ProfitTypeProfit
        displayProfitValue ev.profitAmount, rowIndex, OPGridOrderPlexColumns.profit
    Case TradeBuild.ProfitTypes.ProfitTypeMaxProfit
        displayProfitValue ev.profitAmount, rowIndex, OPGridOrderPlexColumns.MaxProfit
    Case TradeBuild.ProfitTypes.ProfitTypeDrawdown
        displayProfitValue -ev.profitAmount, rowIndex, OPGridOrderPlexColumns.drawdown
    End Select

ElseIf TypeOf ev.Source Is TradeBuild.PositionManager Then
    Dim pmProfitType As TradeBuild.ProfitTypes
    Dim pm As TradeBuild.PositionManager
    Dim pmIndex As Long
    
    Set pm = ev.Source
    
    pmIndex = findPositionManagerTableIndex(pm)
    rowIndex = mPositionManagerGridMappingTable(pmIndex).gridIndex
    pmProfitType = ev.profitType
    
    Select Case pmProfitType
    Case TradeBuild.ProfitTypes.ProfitTypeSessionProfit
        displayProfitValue ev.profitAmount, rowIndex, OPGridPositionColumns.profit
    Case TradeBuild.ProfitTypes.ProfitTypeSessionMaxProfit
        displayProfitValue ev.profitAmount, rowIndex, OPGridPositionColumns.MaxProfit
    Case TradeBuild.ProfitTypes.ProfitTypeSessionDrawdown
        displayProfitValue -ev.profitAmount, rowIndex, OPGridPositionColumns.drawdown
    Case TradeBuild.ProfitTypes.ProfitTypetradeProfit
    Case TradeBuild.ProfitTypes.ProfitTypeTradeMaxProfit
    Case TradeBuild.ProfitTypes.ProfitTypetradeDrawdown
    End Select
End If
End Sub

'================================================================================
' Form Control Event Handlers
'================================================================================

Private Sub EditText_KeyDown(KeyCode As Integer, Shift As Integer)
Select Case KeyCode
Case KeyCodeConstants.vbKeyEscape   ' ESC: hide, return focus to MSHFlexGrid.
   EditText.text = ""
   EditText.Visible = False
   OrderPlexGrid.SetFocus
Case KeyCodeConstants.vbKeyReturn   ' ENTER return focus to MSHFlexGrid.
   OrderPlexGrid.SetFocus
   updateOrderPlex
End Select

End Sub

Private Sub EditText_KeyPress(KeyAscii As Integer)
' Delete returns to get rid of beep.
If KeyAscii = Asc(vbCr) Then KeyAscii = 0
End Sub

Private Sub OrderPlexGrid_Click()
Dim row As Long
Dim rowdata As Long
Dim op As TradeBuild.orderPlex
Dim Index As Long
Dim selectedOrder As TradeBuild.Order

row = OrderPlexGrid.row

If OrderPlexGrid.MouseCol = OPGridColumns.symbol Then
    RaiseEvent Click
    Exit Sub
End If

If OrderPlexGrid.MouseCol = OPGridColumns.ExpandIndicator Then
    expandOrContract
Else

    invertEntryColors mSelectedOrderPlexGridRow
    
    mSelectedOrderPlexGridRow = -1
    
    OrderPlexGrid.row = row
    rowdata = OrderPlexGrid.rowdata(row)
    If rowdata < RowDataPositionManagerBase And _
        rowdata >= RowDataOrderPlexBase _
    Then
        Index = rowdata - RowDataOrderPlexBase
        Set op = mOrderPlexGridMappingTable(Index).op
        If op.State = OrderPlexStateCodes.Created Or _
            op.State = OrderPlexStateCodes.Submitted _
        Then
            
            mSelectedOrderPlexGridRow = row
            Set mSelectedOrderPlex = op
            invertEntryColors mSelectedOrderPlexGridRow
            
            mSelectedOrderIndex = mSelectedOrderPlexGridRow - mOrderPlexGridMappingTable(Index).gridIndex
            If mSelectedOrderIndex = 0 Then Exit Sub
            
            Set selectedOrder = op.Order(mSelectedOrderIndex)
            If selectedOrder.isModifiable Then
                If (OrderPlexGrid.MouseCol = OPGridOrderColumns.price And _
                        selectedOrder.isAttributeModifiable(OrderAttributeIds.OrderAttLimitPrice)) Or _
                    (OrderPlexGrid.MouseCol = OPGridOrderColumns.auxPrice And _
                        selectedOrder.isAttributeModifiable(OrderAttributeIds.OrderAttTriggerPrice)) Or _
                    (OrderPlexGrid.MouseCol = OPGridOrderColumns.quantityRemaining And _
                    selectedOrder.isAttributeModifiable(OrderAttributeIds.OrderAttQuantity)) _
                Then
                    OrderPlexGrid.Col = OrderPlexGrid.MouseCol
                    EditText.Move OrderPlexGrid.Left + OrderPlexGrid.CellLeft + 8, _
                                OrderPlexGrid.Top + OrderPlexGrid.CellTop + 8, _
                                OrderPlexGrid.CellWidth - 16, _
                                OrderPlexGrid.CellHeight - 16
                    EditText.text = OrderPlexGrid.text
                    EditText.SelStart = 0
                    EditText.SelLength = Len(EditText.text)
                    EditText.Visible = True
                    EditText.SetFocus
                End If
            End If
            
        End If
    End If
End If
RaiseEvent Click
RaiseEvent SelectionChanged
End Sub

Private Sub OrderPlexGrid_LeaveCell()
updateOrderPlex
End Sub

Private Sub OrderPlexGrid_Scroll()
If EditText.Visible Then
    EditText.Move OrderPlexGrid.Left + OrderPlexGrid.CellLeft + 8, _
                OrderPlexGrid.Top + OrderPlexGrid.CellTop + 8, _
                OrderPlexGrid.CellWidth - 16, _
                OrderPlexGrid.CellHeight - 16
End If
End Sub

'================================================================================
' Properties
'================================================================================

Public Property Get isSelectedItemModifiable() As Boolean
Dim selectedOrder As TradeBuild.Order

Set selectedOrder = mSelectedOrderPlex.Order(mSelectedOrderIndex)
If Not selectedOrder Is Nothing Then
    isSelectedItemModifiable = selectedOrder.isModifiable
End If
End Property

Public Property Get selectedItem() As orderPlex
Set selectedItem = mSelectedOrderPlex
End Property

Public Property Get selectedOrderIndex() As Long
selectedOrderIndex = mSelectedOrderIndex
End Property

'================================================================================
' Methods
'================================================================================

Public Sub finish()
Dim i As Long
Dim lWorkspace As TradeBuild.WorkSpace

For i = mMonitoredWorkspaces.count To 1 Step -1
    Set lWorkspace = mMonitoredWorkspaces(i)
    lWorkspace.Tickers.removeCollectionChangeListener Me
    lWorkspace.OrderPlexes.removeCollectionChangeListener Me
    mMonitoredWorkspaces.remove i
Next
End Sub

Public Sub monitorWorkspace( _
                ByVal pWorkspace As TradeBuild.WorkSpace)
pWorkspace.Tickers.addCollectionChangeListener Me
pWorkspace.OrderPlexes.addCollectionChangeListener Me
mMonitoredWorkspaces.add pWorkspace
End Sub
                
'================================================================================
' Helper Functions
'================================================================================

Private Function addEntryToOrderPlexGrid( _
                ByVal symbol As String, _
                Optional ByVal before As Boolean, _
                Optional ByVal Index As Long = -1) As Long
Dim i As Long

If Index < 0 Then
    For i = mFirstOrderPlexGridRowIndex To OrderPlexGrid.Rows - 1
        If (before And _
            OrderPlexGrid.TextMatrix(i, OPGridColumns.symbol) >= symbol) Or _
            OrderPlexGrid.TextMatrix(i, OPGridColumns.symbol) = "" _
        Then
            Index = i
            Exit For
        ElseIf (Not before And _
            OrderPlexGrid.TextMatrix(i, OPGridColumns.symbol) > symbol) Or _
            OrderPlexGrid.TextMatrix(i, OPGridColumns.symbol) = "" _
        Then
            Index = i
            Exit For
        End If
    Next
    
    If Index < 0 Then
        OrderPlexGrid.AddItem ""
        Index = OrderPlexGrid.Rows - 1
    ElseIf OrderPlexGrid.TextMatrix(Index, OPGridColumns.symbol) = "" Then
        OrderPlexGrid.TextMatrix(Index, OPGridColumns.symbol) = symbol
    Else
        OrderPlexGrid.AddItem "", Index
    End If
Else
    OrderPlexGrid.AddItem "", Index
End If

OrderPlexGrid.TextMatrix(Index, OPGridColumns.symbol) = symbol
If Index < OrderPlexGrid.Rows - 1 Then
    ' this new entry has displaced one or more existing entries so
    ' the OrderPlexGridMappingTable and PositionManageGridMappingTable indexes
    ' need to be adjusted
    For i = 0 To mMaxOrderPlexGridMappingTableIndex
        If mOrderPlexGridMappingTable(i).gridIndex >= Index Then
            mOrderPlexGridMappingTable(i).gridIndex = mOrderPlexGridMappingTable(i).gridIndex + 1
        End If
    Next
    For i = 0 To mMaxPositionManagerGridMappingTableIndex
        If mPositionManagerGridMappingTable(i).gridIndex >= Index Then
            mPositionManagerGridMappingTable(i).gridIndex = mPositionManagerGridMappingTable(i).gridIndex + 1
        End If
    Next
End If

addEntryToOrderPlexGrid = Index
End Function

Private Function addOrderPlexEntryToOrderPlexGrid( _
                ByVal symbol As String, _
                ByVal orderPlexTableIndex As Long) As Long
Dim Index As Long

Index = addEntryToOrderPlexGrid(symbol, False)

OrderPlexGrid.rowdata(Index) = orderPlexTableIndex + RowDataOrderPlexBase

OrderPlexGrid.row = Index
OrderPlexGrid.Col = OPGridColumns.ExpandIndicator
OrderPlexGrid.CellPictureAlignment = AlignmentSettings.flexAlignCenterCenter
Set OrderPlexGrid.CellPicture = OrderPlexImageList.ListImages("Contract").Picture

OrderPlexGrid.Col = OPGridOrderPlexColumns.profit
OrderPlexGrid.CellBackColor = &HC0C0C0
OrderPlexGrid.CellForeColor = vbWhite

OrderPlexGrid.Col = OPGridOrderPlexColumns.MaxProfit
OrderPlexGrid.CellBackColor = &HC0C0C0
OrderPlexGrid.CellForeColor = vbWhite

OrderPlexGrid.Col = OPGridOrderPlexColumns.drawdown
OrderPlexGrid.CellBackColor = &HC0C0C0
OrderPlexGrid.CellForeColor = vbWhite

addOrderPlexEntryToOrderPlexGrid = Index
End Function
                
Private Sub addOrderEntryToOrderPlexGrid( _
                ByVal Index As Long, _
                ByVal symbol As String, _
                ByVal pOrder As TradeBuild.Order, _
                ByVal orderPlexTableIndex As Long, _
                ByVal typeInPlex As String)


Index = addEntryToOrderPlexGrid(symbol, False, Index)

OrderPlexGrid.rowdata(Index) = orderPlexTableIndex + RowDataOrderPlexBase

OrderPlexGrid.TextMatrix(Index, OPGridOrderColumns.typeInPlex) = typeInPlex

displayOrderValuesInOrderPlexGrid Index, pOrder

End Sub

Private Function contractOrderPlexEntry( _
                ByVal Index As Long, _
                Optional ByVal preserveCurrentExpandedState As Boolean) As Long
Dim lIndex As Long

With mOrderPlexGridMappingTable(Index)
    If .entryGridOffset >= 0 Then
        lIndex = .gridIndex + .entryGridOffset
        OrderPlexGrid.RowHeight(lIndex) = 0
    End If
    If .stopGridOffset >= 0 Then
        lIndex = .gridIndex + .stopGridOffset
        OrderPlexGrid.RowHeight(lIndex) = 0
    End If
    If .targetGridOffset >= 0 Then
        lIndex = .gridIndex + .targetGridOffset
        OrderPlexGrid.RowHeight(lIndex) = 0
    End If
    If .closeoutGridOffset >= 0 Then
        lIndex = .gridIndex + .closeoutGridOffset
        OrderPlexGrid.RowHeight(lIndex) = 0
    End If
    
    If Not preserveCurrentExpandedState Then
        .isExpanded = False
        OrderPlexGrid.row = .gridIndex
        OrderPlexGrid.Col = OPGridColumns.ExpandIndicator
        OrderPlexGrid.CellPictureAlignment = AlignmentSettings.flexAlignCenterCenter
        Set OrderPlexGrid.CellPicture = OrderPlexImageList.ListImages("Expand").Picture
    End If
End With

contractOrderPlexEntry = lIndex
End Function

Private Sub contractPositionManagerEntry(ByVal Index As Long)
Dim i As Long
Dim symbol As String
Dim lOpEntryIndex As Long

mPositionManagerGridMappingTable(Index).isExpanded = False
OrderPlexGrid.row = mPositionManagerGridMappingTable(Index).gridIndex
OrderPlexGrid.Col = OPGridColumns.ExpandIndicator
OrderPlexGrid.CellPictureAlignment = AlignmentSettings.flexAlignCenterCenter
Set OrderPlexGrid.CellPicture = OrderPlexImageList.ListImages("Expand").Picture

symbol = OrderPlexGrid.TextMatrix(mPositionManagerGridMappingTable(Index).gridIndex, OPGridColumns.symbol)
i = mPositionManagerGridMappingTable(Index).gridIndex + 1
Do While OrderPlexGrid.TextMatrix(i, OPGridColumns.symbol) = symbol
    OrderPlexGrid.RowHeight(i) = 0
    lOpEntryIndex = OrderPlexGrid.rowdata(i) - RowDataOrderPlexBase
    i = contractOrderPlexEntry(lOpEntryIndex, True) + 1
Loop
End Sub

Private Sub displayOrderValuesInOrderPlexGrid( _
                ByVal gridIndex As Long, _
                ByVal pOrder As Order)
Dim lTicker As TradeBuild.ticker

Set lTicker = pOrder.ticker

OrderPlexGrid.TextMatrix(gridIndex, OPGridOrderColumns.action) = OrderActionToString(pOrder.action)
OrderPlexGrid.TextMatrix(gridIndex, OPGridOrderColumns.auxPrice) = lTicker.formatPrice(pOrder.triggerPrice, True)
OrderPlexGrid.TextMatrix(gridIndex, OPGridOrderColumns.averagePrice) = lTicker.formatPrice(pOrder.averagePrice, True)
OrderPlexGrid.TextMatrix(gridIndex, OPGridOrderColumns.id) = pOrder.id
OrderPlexGrid.TextMatrix(gridIndex, OPGridOrderColumns.lastFillPrice) = lTicker.formatPrice(pOrder.lastFillPrice, True)
OrderPlexGrid.TextMatrix(gridIndex, OPGridOrderColumns.LastFillTime) = IIf(pOrder.fillTime <> 0, pOrder.fillTime, "")
OrderPlexGrid.TextMatrix(gridIndex, OPGridOrderColumns.orderType) = OrderTypeToString(pOrder.orderType)
OrderPlexGrid.TextMatrix(gridIndex, OPGridOrderColumns.price) = lTicker.formatPrice(pOrder.limitPrice, True)
OrderPlexGrid.TextMatrix(gridIndex, OPGridOrderColumns.quantityRemaining) = pOrder.quantityRemaining
OrderPlexGrid.TextMatrix(gridIndex, OPGridOrderColumns.size) = IIf(pOrder.quantityFilled <> 0, pOrder.quantityFilled, 0)
OrderPlexGrid.TextMatrix(gridIndex, OPGridOrderColumns.Status) = OrderStatusToString(pOrder.Status)
End Sub

Private Sub displayProfitValue( _
                ByVal profit As Currency, _
                ByVal rowIndex As Long, _
                ByVal colIndex As Long)
OrderPlexGrid.row = rowIndex
OrderPlexGrid.Col = colIndex
OrderPlexGrid.text = Format(profit, "0.00")
If profit >= 0 Then
    OrderPlexGrid.CellForeColor = PositiveProfitColor
Else
    OrderPlexGrid.CellForeColor = NegativeProfitColor
End If
End Sub
Private Sub expandOrContract()
Dim rowdata As Long
Dim Index As Long
Dim expanded As Boolean

rowdata = OrderPlexGrid.rowdata(OrderPlexGrid.MouseRow)
If rowdata >= RowDataPositionManagerBase Then
    Index = rowdata - RowDataPositionManagerBase
    expanded = mPositionManagerGridMappingTable(Index).isExpanded
    If expanded Then
        contractPositionManagerEntry Index
    Else
        expandPositionManagerEntry Index
    End If
ElseIf rowdata >= RowDataOrderPlexBase Then
    Index = rowdata - RowDataOrderPlexBase
    expanded = mOrderPlexGridMappingTable(Index).isExpanded
    If OrderPlexGrid.row <> mOrderPlexGridMappingTable(Index).gridIndex Then
        ' clicked on an order entry
        Exit Sub
    End If
    If expanded Then
        contractOrderPlexEntry Index
    Else
        expandOrderPlexEntry Index
    End If
Else
    Exit Sub
End If
End Sub

Private Function expandOrderPlexEntry( _
                ByVal Index As Long, _
                Optional ByVal preserveCurrentExpandedState As Boolean) As Long
Dim lIndex As Long


With mOrderPlexGridMappingTable(Index)
    
    If .entryGridOffset >= 0 Then
        lIndex = .gridIndex + .entryGridOffset
        If Not preserveCurrentExpandedState Or .isExpanded Then OrderPlexGrid.RowHeight(lIndex) = -1
    End If
    If .stopGridOffset >= 0 Then
        lIndex = .gridIndex + .stopGridOffset
        If Not preserveCurrentExpandedState Or .isExpanded Then OrderPlexGrid.RowHeight(lIndex) = -1
    End If
    If .targetGridOffset >= 0 Then
        lIndex = .gridIndex + .targetGridOffset
        If Not preserveCurrentExpandedState Or .isExpanded Then OrderPlexGrid.RowHeight(lIndex) = -1
    End If
    If .closeoutGridOffset >= 0 Then
        lIndex = .gridIndex + .closeoutGridOffset
        If Not preserveCurrentExpandedState Or .isExpanded Then OrderPlexGrid.RowHeight(lIndex) = -1
    End If
    
    If Not preserveCurrentExpandedState Then
        .isExpanded = True
        OrderPlexGrid.row = .gridIndex
        OrderPlexGrid.Col = OPGridColumns.ExpandIndicator
        OrderPlexGrid.CellPictureAlignment = AlignmentSettings.flexAlignCenterCenter
        Set OrderPlexGrid.CellPicture = OrderPlexImageList.ListImages("Contract").Picture
    End If
End With

expandOrderPlexEntry = lIndex
End Function

Private Sub expandPositionManagerEntry(ByVal Index As Long)
Dim i As Long
Dim symbol As String
Dim lOpEntryIndex As Long

mPositionManagerGridMappingTable(Index).isExpanded = True
OrderPlexGrid.row = mPositionManagerGridMappingTable(Index).gridIndex
OrderPlexGrid.Col = OPGridColumns.ExpandIndicator
OrderPlexGrid.CellPictureAlignment = AlignmentSettings.flexAlignCenterCenter
Set OrderPlexGrid.CellPicture = OrderPlexImageList.ListImages("Contract").Picture

symbol = OrderPlexGrid.TextMatrix(mPositionManagerGridMappingTable(Index).gridIndex, OPGridColumns.symbol)
i = mPositionManagerGridMappingTable(Index).gridIndex + 1
Do While OrderPlexGrid.TextMatrix(i, OPGridColumns.symbol) = symbol
    OrderPlexGrid.RowHeight(i) = -1
    lOpEntryIndex = OrderPlexGrid.rowdata(i) - RowDataOrderPlexBase
    i = expandOrderPlexEntry(lOpEntryIndex, True) + 1
Loop
End Sub

Private Function findOrderPlexTableIndex(ByVal op As TradeBuild.orderPlex) As Long
Dim opIndex As Long
Dim lOrder As TradeBuild.Order
Dim symbol As String

' first make sure the relevant PositionManager entry is set up
findPositionManagerTableIndex op.ticker.PositionManager

symbol = op.Contract.specifier.localSymbol
opIndex = op.indexApplication
If opIndex > UBound(mOrderPlexGridMappingTable) Then
    ReDim Preserve mOrderPlexGridMappingTable(UBound(mOrderPlexGridMappingTable) + 50) As OrderPlexGridMappingEntry
End If
If opIndex > mMaxOrderPlexGridMappingTableIndex Then mMaxOrderPlexGridMappingTableIndex = opIndex

With mOrderPlexGridMappingTable(opIndex)
    If .op Is Nothing Then
        
        .isExpanded = True
        .entryGridOffset = -1
        .stopGridOffset = -1
        .targetGridOffset = -1
        .closeoutGridOffset = -1
        
        Set .op = op
        .gridIndex = addOrderPlexEntryToOrderPlexGrid(op.Contract.specifier.localSymbol, opIndex)
        OrderPlexGrid.TextMatrix(.gridIndex, OPGridOrderPlexColumns.creationTime) = op.creationTime
        OrderPlexGrid.TextMatrix(.gridIndex, OPGridOrderPlexColumns.currencyCode) = op.Contract.specifier.currencyCode
        
        Set lOrder = op.entryOrder
        If Not lOrder Is Nothing Then
            .entryGridOffset = 1
            addOrderEntryToOrderPlexGrid .gridIndex + .entryGridOffset, _
                                    symbol, _
                                    lOrder, _
                                    opIndex, _
                                    "Entry"
        End If
        
        Set lOrder = op.stopOrder
        If Not lOrder Is Nothing Then
            If .entryGridOffset >= 0 Then
                .stopGridOffset = .entryGridOffset + 1
            Else
                .stopGridOffset = 1
            End If
            addOrderEntryToOrderPlexGrid .gridIndex + .stopGridOffset, _
                                    symbol, _
                                    lOrder, _
                                    opIndex, _
                                    "Stop"
        End If
        
        Set lOrder = op.targetOrder
        If Not lOrder Is Nothing Then
            If .stopGridOffset >= 0 Then
                .targetGridOffset = .stopGridOffset + 1
            ElseIf .entryGridOffset >= 0 Then
                .targetGridOffset = .entryGridOffset + 1
            Else
                .targetGridOffset = 1
            End If
            addOrderEntryToOrderPlexGrid .gridIndex + .targetGridOffset, _
                                    symbol, _
                                    lOrder, _
                                    opIndex, _
                                    "Target"
        End If
    End If
End With
findOrderPlexTableIndex = opIndex
End Function

Private Function findPositionManagerTableIndex(ByVal pm As TradeBuild.PositionManager) As Long
Dim pmIndex As Long
Dim symbol As String

symbol = pm.ticker.Contract.specifier.localSymbol
pmIndex = pm.indexApplication
If pmIndex > UBound(mPositionManagerGridMappingTable) Then
    ReDim Preserve mPositionManagerGridMappingTable(UBound(mPositionManagerGridMappingTable) + 20) As PositionManagerGridMappingEntry
End If
If pmIndex > mMaxPositionManagerGridMappingTableIndex Then mMaxPositionManagerGridMappingTableIndex = pmIndex

With mPositionManagerGridMappingTable(pmIndex)
    If .pm Is Nothing Then
        Set .pm = pm
        .gridIndex = addEntryToOrderPlexGrid(pm.ticker.Contract.specifier.localSymbol, True)
        OrderPlexGrid.rowdata(.gridIndex) = pmIndex + RowDataPositionManagerBase
        OrderPlexGrid.row = .gridIndex
        OrderPlexGrid.Col = 1
        OrderPlexGrid.ColSel = OrderPlexGrid.Cols - 1
        OrderPlexGrid.FillStyle = FillStyleSettings.flexFillRepeat
        OrderPlexGrid.CellBackColor = &HC0C0C0
        OrderPlexGrid.CellForeColor = vbWhite
        OrderPlexGrid.CellFontBold = True
        OrderPlexGrid.TextMatrix(.gridIndex, OPGridPositionColumns.exchange) = pm.ticker.Contract.specifier.exchange
        OrderPlexGrid.TextMatrix(.gridIndex, OPGridPositionColumns.currencyCode) = pm.ticker.Contract.specifier.currencyCode
        OrderPlexGrid.TextMatrix(.gridIndex, OPGridPositionColumns.size) = pm.positionSize
        OrderPlexGrid.Col = OPGridColumns.ExpandIndicator
        OrderPlexGrid.CellPictureAlignment = AlignmentSettings.flexAlignCenterCenter
        Set OrderPlexGrid.CellPicture = OrderPlexImageList.ListImages("Contract").Picture
        .isExpanded = True
    End If
End With
findPositionManagerTableIndex = pmIndex
End Function

Private Sub invertEntryColors(ByVal rowNumber As Long)
Dim foreColor As Long
Dim backColor As Long
Dim i As Long

If rowNumber < 0 Then Exit Sub

OrderPlexGrid.row = rowNumber

For i = OPGridColumns.OtherColumns To OrderPlexGrid.Cols - 1
    OrderPlexGrid.Col = i
    foreColor = IIf(OrderPlexGrid.CellForeColor = 0, OrderPlexGrid.foreColor, OrderPlexGrid.CellForeColor)
    If foreColor = SystemColorConstants.vbWindowText Then
        OrderPlexGrid.CellForeColor = SystemColorConstants.vbHighlightText
    ElseIf foreColor = SystemColorConstants.vbHighlightText Then
        OrderPlexGrid.CellForeColor = SystemColorConstants.vbWindowText
    ElseIf foreColor > 0 Then
        OrderPlexGrid.CellForeColor = IIf((foreColor Xor &HFFFFFF) = 0, 1, foreColor Xor &HFFFFFF)
    End If
    
    backColor = IIf(OrderPlexGrid.CellBackColor = 0, OrderPlexGrid.backColor, OrderPlexGrid.CellBackColor)
    If backColor = SystemColorConstants.vbWindowBackground Then
        OrderPlexGrid.CellBackColor = SystemColorConstants.vbHighlight
    ElseIf backColor = SystemColorConstants.vbHighlight Then
        OrderPlexGrid.CellBackColor = SystemColorConstants.vbWindowBackground
    ElseIf backColor > 0 Then
        OrderPlexGrid.CellBackColor = IIf((backColor Xor &HFFFFFF) = 0, 1, backColor Xor &HFFFFFF)
    End If
Next

End Sub

Private Function isValidLong(value As String) As Boolean
Dim longValue As Long
Dim floatValue As Double

If value = "" Then
    isValidLong = True
ElseIf IsNumeric(value) Then
    floatValue = CDbl(value)
    If floatValue < 0 Or floatValue > &H7FFFFFFF Then Exit Function
    longValue = CLng(floatValue)
    If longValue <> floatValue Then Exit Function
    isValidLong = True
End If
End Function

Private Sub setupOrderPlexGrid()
With OrderPlexGrid
    mSelectedOrderPlexGridRow = -1
    .AllowUserResizing = flexResizeBoth
    
    .Cols = 0
    .Rows = 20
    .FixedRows = 3
    ' .FixedCols = 1
    
    setupOrderPlexGridColumn 0, OPGridColumns.ExpandIndicator, OPGridColumnWidths.ExpandIndicatorWidth, "", True, AlignmentSettings.flexAlignCenterCenter
    setupOrderPlexGridColumn 0, OPGridColumns.symbol, OPGridColumnWidths.SymbolWidth, "Symbol", True, AlignmentSettings.flexAlignLeftCenter
    
    setupOrderPlexGridColumn 0, OPGridPositionColumns.currencyCode, OPGridPositionColumnWidths.CurrencyCodeWidth, "Curr", True, AlignmentSettings.flexAlignLeftCenter
    setupOrderPlexGridColumn 0, OPGridPositionColumns.drawdown, OPGridPositionColumnWidths.DrawdownWidth, "Drawdown", False, AlignmentSettings.flexAlignRightCenter
    setupOrderPlexGridColumn 0, OPGridPositionColumns.exchange, OPGridPositionColumnWidths.ExchangeWidth, "Exchange", True, AlignmentSettings.flexAlignLeftCenter
    setupOrderPlexGridColumn 0, OPGridPositionColumns.MaxProfit, OPGridPositionColumnWidths.MaxProfitWidth, "Max", False, AlignmentSettings.flexAlignRightCenter
    setupOrderPlexGridColumn 0, OPGridPositionColumns.profit, OPGridPositionColumnWidths.ProfitWidth, "Profit", False, AlignmentSettings.flexAlignRightCenter
    setupOrderPlexGridColumn 0, OPGridPositionColumns.size, OPGridPositionColumnWidths.SizeWidth, "Size", False, AlignmentSettings.flexAlignRightCenter
    
    setupOrderPlexGridColumn 1, OPGridOrderPlexColumns.creationTime, OPGridOrderPlexColumnWidths.CreationTimeWidth, "Creation Time", False, AlignmentSettings.flexAlignRightCenter
    setupOrderPlexGridColumn 1, OPGridOrderPlexColumns.currencyCode, OPGridOrderPlexColumnWidths.CurrencyCodeWidth, "Curr", True, AlignmentSettings.flexAlignLeftCenter
    setupOrderPlexGridColumn 1, OPGridOrderPlexColumns.drawdown, OPGridOrderPlexColumnWidths.DrawdownWidth, "Drawdown", False, AlignmentSettings.flexAlignRightCenter
    setupOrderPlexGridColumn 1, OPGridOrderPlexColumns.MaxProfit, OPGridOrderPlexColumnWidths.MaxProfitWidth, "Max", False, AlignmentSettings.flexAlignRightCenter
    setupOrderPlexGridColumn 1, OPGridOrderPlexColumns.profit, OPGridOrderPlexColumnWidths.ProfitWidth, "Profit", False, AlignmentSettings.flexAlignRightCenter
    setupOrderPlexGridColumn 1, OPGridOrderPlexColumns.size, OPGridOrderPlexColumnWidths.SizeWidth, "Size", False, AlignmentSettings.flexAlignRightCenter
    
    setupOrderPlexGridColumn 2, OPGridOrderColumns.action, OPGridOrderColumnWidths.ActionWidth, "Action", True, AlignmentSettings.flexAlignLeftCenter
    setupOrderPlexGridColumn 2, OPGridOrderColumns.auxPrice, OPGridOrderColumnWidths.AuxPriceWidth, "Trigger", False, AlignmentSettings.flexAlignRightCenter
    setupOrderPlexGridColumn 2, OPGridOrderColumns.averagePrice, OPGridOrderColumnWidths.AveragePriceWidth, "Avg", False, AlignmentSettings.flexAlignRightCenter
    setupOrderPlexGridColumn 2, OPGridOrderColumns.id, OPGridOrderColumnWidths.IdWidth, "Id", True, AlignmentSettings.flexAlignLeftCenter
    setupOrderPlexGridColumn 2, OPGridOrderColumns.lastFillPrice, OPGridOrderColumnWidths.LastFillPriceWidth, "Fill", False, AlignmentSettings.flexAlignRightCenter
    setupOrderPlexGridColumn 2, OPGridOrderColumns.LastFillTime, OPGridOrderColumnWidths.LastFillTimeWidth, "Last fill time", False, AlignmentSettings.flexAlignRightCenter
    setupOrderPlexGridColumn 2, OPGridOrderColumns.orderType, OPGridOrderColumnWidths.OrderTypeWidth, "Order type", True, AlignmentSettings.flexAlignLeftCenter
    setupOrderPlexGridColumn 2, OPGridOrderColumns.price, OPGridOrderColumnWidths.PriceWidth, "Price", False, AlignmentSettings.flexAlignRightCenter
    setupOrderPlexGridColumn 2, OPGridOrderColumns.quantityRemaining, OPGridOrderColumnWidths.QuantityWidth, "Rem Qty", False, AlignmentSettings.flexAlignRightCenter
    setupOrderPlexGridColumn 2, OPGridOrderColumns.size, OPGridOrderColumnWidths.SizeWidth, "Size", False, AlignmentSettings.flexAlignRightCenter
    setupOrderPlexGridColumn 2, OPGridOrderColumns.Status, OPGridOrderColumnWidths.StatusWidth, "Status", True, AlignmentSettings.flexAlignLeftCenter
    setupOrderPlexGridColumn 2, OPGridOrderColumns.typeInPlex, OPGridOrderColumnWidths.TypeInPlexWidth, "Mode", True, AlignmentSettings.flexAlignLeftCenter
    setupOrderPlexGridColumn 2, OPGridOrderColumns.VendorId, OPGridOrderColumnWidths.VendorIdWidth, "Vendor id", True, AlignmentSettings.flexAlignLeftCenter
    
    .MergeCells = flexMergeFree
    .MergeCol(OPGridColumns.symbol) = True
    .SelectionMode = flexSelectionByRow
    .HighLight = flexHighlightAlways
    .FocusRect = flexFocusNone
    
    mFirstOrderPlexGridRowIndex = 3
End With

EditText.text = ""
End Sub

Private Sub setupOrderPlexGridColumn( _
                ByVal rowNumber As Long, _
                ByVal columnNumber As Long, _
                ByVal columnWidth As Single, _
                ByVal columnHeader As String, _
                ByVal isLetters As Boolean, _
                ByVal align As AlignmentSettings)
    
Dim lColumnWidth As Long

With OrderPlexGrid
    .row = rowNumber
    If (columnNumber + 1) > .Cols Then
        .Cols = columnNumber + 1
        .ColWidth(columnNumber) = 0
    End If
    
    If isLetters Then
        lColumnWidth = mLetterWidth * columnWidth
    Else
        lColumnWidth = mDigitWidth * columnWidth
    End If
    
    If .ColWidth(columnNumber) < lColumnWidth Then
        .ColWidth(columnNumber) = lColumnWidth
    End If
    
    .ColAlignment(columnNumber) = align
    .TextMatrix(rowNumber, columnNumber) = columnHeader
End With
End Sub
                
Private Sub updateOrderPlex()
Dim orderNumber As Long
Dim price As Double

If Not EditText.Visible Then Exit Sub

orderNumber = mSelectedOrderPlexGridRow - mOrderPlexGridMappingTable(OrderPlexGrid.rowdata(OrderPlexGrid.row) - RowDataOrderPlexBase).gridIndex
If OrderPlexGrid.Col = OPGridOrderColumns.price Then
    If mSelectedOrderPlex.Contract.parsePrice(EditText.text, price) Then
        mSelectedOrderPlex.newOrderPrice(orderNumber) = price
    End If
ElseIf OrderPlexGrid.Col = OPGridOrderColumns.auxPrice Then
    If mSelectedOrderPlex.Contract.parsePrice(EditText.text, price) Then
        mSelectedOrderPlex.newOrderTriggerPrice(orderNumber) = price
    End If
ElseIf OrderPlexGrid.Col = OPGridOrderColumns.quantityRemaining Then
    If IsNumeric(EditText.text) Then
        mSelectedOrderPlex.newQuantity = EditText.text
    End If
End If
    
If mSelectedOrderPlex.Dirty Then mSelectedOrderPlex.Update

EditText.Visible = False
End Sub

