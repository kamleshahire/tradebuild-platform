Attribute VB_Name = "Globals"
Option Explicit

''
' Description here
'
' @remarks
' @see
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

Public Const ProjectName                                As String = "ContractUtils27"
Private Const ModuleName                                As String = "Globals"

Public Const ConfigSectionContractSpecifier             As String = "Specifier"

Public Const ConfigSettingContractSpecCurrency          As String = "&Currency"
Public Const ConfigSettingContractSpecExpiry            As String = "&Expiry"
Public Const ConfigSettingContractSpecExchange          As String = "&Exchange"
Public Const ConfigSettingContractSpecLocalSymbol       As String = "&LocalSymbol"
Public Const ConfigSettingContractSpecMultiplier        As String = "&Multiplier"
Public Const ConfigSettingContractSpecRight             As String = "&Right"
Public Const ConfigSettingContractSpecSecType           As String = "&SecType"
Public Const ConfigSettingContractSpecStrikePrice       As String = "&StrikePrice"
Public Const ConfigSettingContractSpecSymbol            As String = "&Symbol"

Public Const ConfigSettingDaysBeforeExpiryToSwitch      As String = "&DaysBeforeExpiryToSwitch"
Public Const ConfigSettingDescription                   As String = "&Description"
Public Const ConfigSettingExpiryDate                    As String = "&ExpiryDate"
Public Const ConfigSettingMultiplier                    As String = "&Multiplier"
Public Const ConfigSettingSessionEndTime                As String = "&SessionEndTime"
Public Const ConfigSettingSessionStartTime              As String = "&SessionStartTime"
Public Const ConfigSettingTickSize                      As String = "&TickSize"
Public Const ConfigSettingTimezoneName                  As String = "&Timezone"

Public Const DefaultDaysBeforeExpiryToSwitch            As Long = 0
Public Const DefaultExpiry                              As String = ""
Public Const DefaultMultiplier                          As Double = 1#
Public Const DefaultTickSize                            As Double = 0.01
Public Const DefaultTimezoneName                        As String = "Eastern Standard Time"

'@================================================================================
' Member variables
'@================================================================================

Private mExchangeCodes()                                As String
Private mMaxExchangeCodesIndex                          As Long

Private mMaxCurrencyDescsIndex                          As Long
Private mCurrencyDescs()                                As CurrencyDescriptor

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

'@================================================================================
' Methods
'@================================================================================

Public Function gContractSpecsCompatible( _
                ByVal pContractSpec1 As IContractSpecifier, _
                ByVal pContractSpec2 As IContractSpecifier) As Boolean
Const ProcName As String = "gContractSpecsCompatible"
On Error GoTo Err

If pContractSpec1.LocalSymbol <> "" And pContractSpec1.LocalSymbol <> pContractSpec2.LocalSymbol Then Exit Function
If pContractSpec1.Symbol <> "" And pContractSpec1.Symbol <> pContractSpec2.Symbol Then Exit Function
If pContractSpec1.SecType <> SecTypeNone And pContractSpec1.SecType <> pContractSpec2.SecType Then Exit Function
If pContractSpec1.Exchange <> "" And pContractSpec1.Exchange <> pContractSpec2.Exchange Then Exit Function
If pContractSpec1.Expiry <> "" And pContractSpec1.Expiry <> Left$(pContractSpec2.Expiry, Len(pContractSpec1.Expiry)) Then Exit Function
If pContractSpec1.Multiplier <> pContractSpec2.Multiplier Then Exit Function
If pContractSpec1.CurrencyCode <> "" And pContractSpec1.CurrencyCode <> pContractSpec2.CurrencyCode Then Exit Function
If pContractSpec1.Right <> OptNone And pContractSpec1.Right <> pContractSpec2.Right Then Exit Function
If pContractSpec1.Strike <> 0# And pContractSpec1.Strike <> pContractSpec2.Strike Then Exit Function

gContractSpecsCompatible = True

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Function gContractSpecsCompare( _
                ByVal pContractSpec1 As IContractSpecifier, _
                ByVal pContractSpec2 As IContractSpecifier, _
                ByRef pSortkeys() As ContractSortKeyIds) As Long
Const ProcName As String = "gContractSpecsCompare"
On Error GoTo Err

Dim i As Long
For i = 0 To UBound(pSortkeys)
    Select Case pSortkeys(i)
    Case ContractSortKeyNone
        Exit Function
    Case ContractSortKeyLocalSymbol
        gContractSpecsCompare = StrComp(pContractSpec1.LocalSymbol, pContractSpec2.LocalSymbol, vbTextCompare)
    Case ContractSortKeySymbol
        gContractSpecsCompare = StrComp(pContractSpec1.Symbol, pContractSpec2.Symbol, vbTextCompare)
    Case ContractSortKeySecType
        gContractSpecsCompare = StrComp(gSecTypeToShortString(pContractSpec1.SecType), gSecTypeToShortString(pContractSpec2.SecType), vbTextCompare)
    Case ContractSortKeyExchange
        gContractSpecsCompare = StrComp(pContractSpec1.Exchange, pContractSpec2.Exchange, vbTextCompare)
    Case ContractSortKeyExpiry
        gContractSpecsCompare = StrComp(pContractSpec1.Expiry, pContractSpec2.Expiry, vbTextCompare)
    Case ContractSortKeyMultiplier
        gContractSpecsCompare = StrComp(pContractSpec1.Multiplier, pContractSpec2.Multiplier, vbBinaryCompare)
    Case ContractSortKeyCurrency
        gContractSpecsCompare = StrComp(pContractSpec1.CurrencyCode, pContractSpec2.CurrencyCode, vbTextCompare)
    Case ContractSortKeyRight
        gContractSpecsCompare = StrComp(gOptionRightToString(pContractSpec1.Right), gOptionRightToString(pContractSpec2.Right), vbTextCompare)
    Case ContractSortKeyStrike
        gContractSpecsCompare = Sgn(pContractSpec1.Strike - pContractSpec2.Strike)
    End Select
    If gContractSpecsCompare <> 0 Then Exit Function
Next

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Function gContractSpecsEqual( _
                ByVal pContractSpec1 As IContractSpecifier, _
                ByVal pContractSpec2 As IContractSpecifier) As Boolean
Const ProcName As String = "gContractSpecsEqual"
On Error GoTo Err

If pContractSpec1 Is Nothing Then Exit Function
If pContractSpec2 Is Nothing Then Exit Function
If pContractSpec1 Is pContractSpec2 Then
    gContractSpecsEqual = True
Else
    gContractSpecsEqual = (gGetContractSpecKey(pContractSpec1) = gGetContractSpecKey(pContractSpec2))
    If pContractSpec1.CurrencyCode <> pContractSpec2.CurrencyCode Then Exit Function
    If pContractSpec1.Exchange <> pContractSpec2.Exchange Then Exit Function
    If pContractSpec1.Expiry <> pContractSpec2.Expiry Then Exit Function
    If pContractSpec1.LocalSymbol <> pContractSpec2.LocalSymbol Then Exit Function
    If pContractSpec1.Multiplier <> pContractSpec2.Multiplier Then Exit Function
    If pContractSpec1.Right <> pContractSpec2.Right Then Exit Function
    If pContractSpec1.SecType <> pContractSpec2.SecType Then Exit Function
    If pContractSpec1.Strike <> pContractSpec2.Strike Then Exit Function
    If pContractSpec1.Symbol <> pContractSpec2.Symbol Then Exit Function
    gContractSpecsEqual = True
End If

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Function gContractToString(ByVal pContract As IContract) As String
Const ProcName As String = "gContractToString"
On Error GoTo Err

gContractToString = "Specifier=(" & pContract.Specifier.ToString & "); " & _
            "Description=" & pContract.Description & "; " & _
            "Expiry date=" & pContract.ExpiryDate & "; " & _
            "Tick size=" & pContract.TickSize & "; " & _
            "Session start=" & FormatDateTime(pContract.SessionStartTime, vbShortTime) & "; " & _
            "Session end=" & FormatDateTime(pContract.SessionEndTime, vbShortTime) & "; " & _
            "TimezoneName=" & pContract.TimezoneName

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Function gContractToXML(ByVal pContract As IContract) As String
Dim XMLdoc As DOMDocument30
Dim lContractElement As IXMLDOMElement
Dim Specifier As IXMLDOMElement
Dim ComboLegs As IXMLDOMElement
Dim ComboLeg As IXMLDOMElement
Dim comboLegObj As ComboLeg

Const ProcName As String = "gContractToXML"

On Error GoTo Err

Set XMLdoc = New DOMDocument30
Set lContractElement = XMLdoc.createElement("contract")
Set XMLdoc.documentElement = lContractElement
lContractElement.setAttribute "xmlns", "urn:tradewright.com:tradebuild"
lContractElement.setAttribute "minimumtick", pContract.TickSize
lContractElement.setAttribute "sessionstarttime", Format(pContract.SessionStartTime, "hh:mm:ss")
lContractElement.setAttribute "sessionendtime", Format(pContract.SessionEndTime, "hh:mm:ss")
lContractElement.setAttribute "Description", pContract.Description
lContractElement.setAttribute "numberofdecimals", pContract.NumberOfDecimals
lContractElement.setAttribute "timezonename", pContract.TimezoneName

Set Specifier = XMLdoc.createElement("specifier")
lContractElement.appendChild Specifier
Specifier.setAttribute "symbol", pContract.Specifier.Symbol
Specifier.setAttribute "sectype", pContract.Specifier.SecType
Specifier.setAttribute "expiry", pContract.Specifier.Expiry
Specifier.setAttribute "exchange", pContract.Specifier.Exchange
Specifier.setAttribute "currencycode", pContract.Specifier.CurrencyCode
Specifier.setAttribute "localsymbol", pContract.Specifier.LocalSymbol
Specifier.setAttribute "multiplier", pContract.Specifier.Multiplier
Specifier.setAttribute "right", pContract.Specifier.Right
Specifier.setAttribute "strike", pContract.Specifier.Strike

Set ComboLegs = XMLdoc.createElement("combolegs")
Specifier.appendChild ComboLegs
If Not pContract.Specifier.ComboLegs Is Nothing Then
    For Each comboLegObj In pContract.Specifier.ComboLegs
        Set ComboLeg = XMLdoc.createElement("comboleg")
        ComboLegs.appendChild ComboLeg
        
        Set Specifier = XMLdoc.createElement("specifier")
        ComboLeg.appendChild Specifier
        ComboLeg.setAttribute "isBuyLeg", comboLegObj.IsBuyLeg
        ComboLeg.setAttribute "Ratio", comboLegObj.Ratio
        Specifier.setAttribute "symbol", pContract.Specifier.Symbol
        Specifier.setAttribute "sectype", pContract.Specifier.SecType
        Specifier.setAttribute "expiry", pContract.Specifier.Expiry
        Specifier.setAttribute "exchange", pContract.Specifier.Exchange
        Specifier.setAttribute "currencycode", pContract.Specifier.CurrencyCode
        Specifier.setAttribute "localsymbol", pContract.Specifier.LocalSymbol
        Specifier.setAttribute "right", pContract.Specifier.Right
        Specifier.setAttribute "strike", pContract.Specifier.Strike
    Next
End If
gContractToXML = XMLdoc.xml

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Function gCreateContractSpecifier( _
                ByVal LocalSymbol As String, _
                ByVal Symbol As String, _
                ByVal Exchange As String, _
                ByVal SecType As SecurityTypes, _
                ByVal CurrencyCode As String, _
                ByVal Expiry As String, _
                ByVal Multiplier As Double, _
                ByVal Strike As Double, _
                ByVal Right As OptionRights) As ContractSpecifier
Const ProcName As String = "gCreateContractSpecifier"
On Error GoTo Err

Set gCreateContractSpecifier = New ContractSpecifier
gCreateContractSpecifier.Initialise LocalSymbol, Symbol, Exchange, SecType, CurrencyCode, Expiry, Multiplier, Strike, Right

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Function gGetContractSpecKey(ByVal pSpec As IContractSpecifier) As String
Const ProcName As String = "gGetContractSpecKey"

On Error GoTo Err

gGetContractSpecKey = pSpec.LocalSymbol & "|" & _
    CStr(pSpec.SecType) & "|" & _
    pSpec.Symbol & "|" & _
    pSpec.Expiry & "|" & _
    pSpec.Strike & "|" & _
    CStr(pSpec.Right) & "|" & _
    pSpec.Exchange & "|" & _
    pSpec.CurrencyCode & "|" & _
    pSpec.Multiplier

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Function gGetCurrencyDescriptor( _
                ByVal Code As String) As CurrencyDescriptor
Const ProcName As String = "gGetCurrencyDescriptor"
On Error GoTo Err

If mMaxCurrencyDescsIndex = 0 Then setupCurrencyDescs
Dim index As Long
index = getCurrencyIndex(Code)
AssertArgument index >= 0, "Invalid currency Code"

gGetCurrencyDescriptor = mCurrencyDescs(index)

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Function gGetCurrencyDescriptors() As CurrencyDescriptor()
Const ProcName As String = "gGetCurrencyDescriptors"
On Error GoTo Err

If mMaxCurrencyDescsIndex = 0 Then setupCurrencyDescs
gGetCurrencyDescriptors = mCurrencyDescs

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Function gGetExchangeCodes() As String()
Const ProcName As String = "gGetExchangeCodes"

On Error GoTo Err

If mMaxExchangeCodesIndex = 0 Then setupExchangeCodes
gGetExchangeCodes = mExchangeCodes

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Sub gHandleUnexpectedError( _
                ByRef pProcedureName As String, _
                ByRef pModuleName As String, _
                Optional ByRef pFailpoint As String, _
                Optional ByVal pReRaise As Boolean = True, _
                Optional ByVal pLog As Boolean = False, _
                Optional ByVal pErrorNumber As Long, _
                Optional ByRef pErrorDesc As String, _
                Optional ByRef pErrorSource As String)
Dim errSource As String: errSource = IIf(pErrorSource <> "", pErrorSource, Err.Source)
Dim errDesc As String: errDesc = IIf(pErrorDesc <> "", pErrorDesc, Err.Description)
Dim errNum As Long: errNum = IIf(pErrorNumber <> 0, pErrorNumber, Err.Number)

HandleUnexpectedError pProcedureName, ProjectName, pModuleName, pFailpoint, pReRaise, pLog, errNum, errDesc, errSource
End Sub

Public Function gLoadContractFromConfig(ByVal pConfig As ConfigurationSection) As IContract
Const ProcName As String = "gLoadContractFromConfig"
On Error GoTo Err

Dim lContract As New Contract
Dim lSpec As ContractSpecifier
Set lSpec = gLoadContractSpecFromConfig(pConfig.AddConfigurationSection(ConfigSectionContractSpecifier))
lContract.Specifier = lSpec

With pConfig
    lContract.DaysBeforeExpiryToSwitch = .GetSetting(ConfigSettingDaysBeforeExpiryToSwitch, DefaultDaysBeforeExpiryToSwitch)
    lContract.Description = .GetSetting(ConfigSettingDescription, "")
    lContract.ExpiryDate = CDate(.GetSetting(ConfigSettingExpiryDate, DefaultExpiry))
    lContract.SessionEndTime = .GetSetting(ConfigSettingSessionEndTime, "00:00:00")
    lContract.SessionStartTime = .GetSetting(ConfigSettingSessionStartTime, "00:00:00")
    lContract.TickSize = .GetSetting(ConfigSettingTickSize, DefaultTickSize)
    lContract.TimezoneName = .GetSetting(ConfigSettingTimezoneName, DefaultTimezoneName)
    If .GetSetting(ConfigSettingMultiplier, DefaultMultiplier) <> DefaultMultiplier Then
        lSpec.Multiplier = .GetSetting(ConfigSettingMultiplier, DefaultMultiplier)
    End If
End With

Set gLoadContractFromConfig = lContract

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Function gLoadContractSpecFromConfig(ByVal pConfig As ConfigurationSection) As ContractSpecifier
Const ProcName As String = "gLoadContractSpecFromConfig"
On Error GoTo Err

Dim lContractSpec As ContractSpecifier
With pConfig
    Set lContractSpec = gCreateContractSpecifier(.GetSetting(ConfigSettingContractSpecLocalSymbol, ""), _
                                            .GetSetting(ConfigSettingContractSpecSymbol, ""), _
                                            .GetSetting(ConfigSettingContractSpecExchange, ""), _
                                            gSecTypeFromString(.GetSetting(ConfigSettingContractSpecSecType, "")), _
                                            .GetSetting(ConfigSettingContractSpecCurrency, ""), _
                                            .GetSetting(ConfigSettingContractSpecExpiry, ""), _
                                            .GetSetting(ConfigSettingContractSpecMultiplier, DefaultMultiplier), _
                                            CDbl(.GetSetting(ConfigSettingContractSpecStrikePrice, "0.0")), _
                                            gOptionRightFromString(.GetSetting(ConfigSettingContractSpecRight, "")))

End With

Set gLoadContractSpecFromConfig = lContractSpec

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Sub gNotifyUnhandledError( _
                ByRef pProcedureName As String, _
                ByRef pModuleName As String, _
                Optional ByRef pFailpoint As String, _
                Optional ByVal pErrorNumber As Long, _
                Optional ByRef pErrorDesc As String, _
                Optional ByRef pErrorSource As String)
Dim errSource As String: errSource = IIf(pErrorSource <> "", pErrorSource, Err.Source)
Dim errDesc As String: errDesc = IIf(pErrorDesc <> "", pErrorDesc, Err.Description)
Dim errNum As Long: errNum = IIf(pErrorNumber <> 0, pErrorNumber, Err.Number)

UnhandledErrorHandler.Notify pProcedureName, pModuleName, ProjectName, pFailpoint, errNum, errDesc, errSource
End Sub

Public Function gIsContractExpired(ByVal pContract As IContract) As Boolean
Const ProcName As String = "gIsContractExpired"
On Error GoTo Err

Select Case pContract.Specifier.SecType
Case SecTypeFuture, SecTypeOption, SecTypeFuturesOption
    If Int(pContract.ExpiryDate) < Int(Now) Then gIsContractExpired = True
End Select

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Function gIsValidCurrencyCode(ByVal Code As String) As Boolean
Const ProcName As String = "gIsValidCurrencyCode"
On Error GoTo Err

gIsValidCurrencyCode = (getCurrencyIndex(Code) >= 0)

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Function gIsValidExchangeCode(ByVal Code As String) As Boolean
Dim bottom As Long
Dim top As Long
Dim middle As Long

Const ProcName As String = "gIsValidExchangeCode"

On Error GoTo Err

If mMaxExchangeCodesIndex = 0 Then setupExchangeCodes

Code = UCase$(Code)
bottom = 0
top = mMaxExchangeCodesIndex
middle = Fix((bottom + top) / 2)

Do
    If Code < mExchangeCodes(middle) Then
        top = middle
    ElseIf Code > mExchangeCodes(middle) Then
        bottom = middle
    Else
        gIsValidExchangeCode = True
        Exit Function
    End If
    middle = Fix((bottom + top) / 2)
Loop Until bottom = middle

If Code = mExchangeCodes(middle) Then gIsValidExchangeCode = True

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Function gIsValidExpiry( _
                ByVal Value As String) As Boolean
Const ProcName As String = "gIsValidExpiry"
On Error GoTo Err

Dim d As Date

If IsDate(Value) Then
    d = CDate(Value)
ElseIf Len(Value) = 8 Then
    Dim datestring As String
    datestring = Left$(Value, 4) & "/" & Mid$(Value, 5, 2) & "/" & Right$(Value, 2)
    If IsDate(datestring) Then d = CDate(datestring)
End If

If d <> 0 Then
    If d >= CDate((Year(Now) - 20) & "/01/01") And d <= CDate((Year(Now) + 10) & "/12/31") Then
        gIsValidExpiry = True
        Exit Function
    End If
End If

If Len(Value) = 6 Then
    If IsInteger(Value, (Year(Now) - 20) * 100 + 1, (Year(Now) + 10) * 100 + 12) Then
        If Right$(Value, 2) <= 12 Then
            gIsValidExpiry = True
            Exit Function
        End If
    End If
End If

gIsValidExpiry = False

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Function gIsValidPrice( _
                ByVal pPrice As Double, _
                ByVal pPrevValidPrice As Double, _
                ByVal pSecType As SecurityTypes, _
                ByVal pTickSize As Double) As Boolean
Const ProcName As String = "gIsValidPrice"
On Error GoTo Err

If pTickSize = 0 Then
    gIsValidPrice = True
    Exit Function
End If

If pPrevValidPrice = 0 Or pPrevValidPrice = MaxDouble Then
    If Abs(pPrice) / pTickSize > &H3FFFFF Then Exit Function ' note that Z index has ticksize 0.01
                                                            ' so we need to allow plenty of room
                                                            ' &H3FFFFF = 4194303
    
    ' A first price of 0 is always considered invalid. Although some indexes can validly
    ' have zero values, it is unlikely on the very first price notified, and this check
    ' catches the occasional zero prices sent by IB when, for example, the Z ticker
    ' is started
    If pPrice = 0 Then Exit Function
    
    If pSecType = SecTypeIndex Then
        ' don't do this check for indexes because some of them, such as TICK-NYSE, can have both
        ' positive, zero and negative values
    Else
        If pPrice < 0 Then Exit Function
        If pPrice / pTickSize < 1 Then Exit Function ' catch occasional very small prices from IB
    End If
Else
    'If Abs(pPrevValidPrice - pPrice) / pTickSize > 32767 Then Exit Function
    
    If pSecType = SecTypeIndex Then
        ' don't do this check for indexes because some of them, such as TICK-NYSE, can have both
        ' positive and negative values - moreover the value can change dramatically from one
        ' tick to the next
    Else
        If pPrice <= 0 Then Exit Function
        If pPrice / pTickSize < 1 Then Exit Function ' catch occasional very small prices from IB
        'If pPrice < (2 * pPrevValidPrice) / 3 Or pPrice > (3 * pPrevValidPrice) / 2 Then Exit Function
    End If
    
End If

gIsValidPrice = True

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Public Function gIsValidSecType( _
                ByVal Value As Long) As Boolean
gIsValidSecType = True
Select Case Value
Case SecTypeStock
Case SecTypeFuture
Case SecTypeOption
Case SecTypeFuturesOption
Case SecTypeCash
Case SecTypeCombo
Case SecTypeIndex
Case Else
    gIsValidSecType = False
End Select
End Function

Public Function gOptionRightFromString(ByVal Value As String) As OptionRights
Select Case UCase$(Value)
Case ""
    gOptionRightFromString = OptNone
Case "CALL", "C"
    gOptionRightFromString = OptCall
Case "PUT", "P"
    gOptionRightFromString = OptPut
End Select
End Function

Public Function gOptionRightToString(ByVal Value As OptionRights) As String
Select Case Value
Case OptNone
    gOptionRightToString = ""
Case OptCall
    gOptionRightToString = "Call"
Case OptPut
    gOptionRightToString = "Put"
End Select
End Function

Public Property Get gRegExp() As RegExp
Static lRegExp As RegExp
Const ProcName As String = "gRegExp"
On Error GoTo Err

If lRegExp Is Nothing Then Set lRegExp = New RegExp
Set gRegExp = lRegExp

Exit Property

Err:
gHandleUnexpectedError ProcName, ModuleName
End Property

Public Sub gSaveContractSpecToConfig(ByVal pContractSpec As IContractSpecifier, ByVal pConfig As ConfigurationSection)
Const ProcName As String = "gSaveContractSpecToConfig"
On Error GoTo Err

With pConfig
    .SetSetting ConfigSettingContractSpecLocalSymbol, pContractSpec.LocalSymbol
    .SetSetting ConfigSettingContractSpecSymbol, pContractSpec.Symbol
    .SetSetting ConfigSettingContractSpecExchange, pContractSpec.Exchange
    .SetSetting ConfigSettingContractSpecSecType, gSecTypeToString(pContractSpec.SecType)
    .SetSetting ConfigSettingContractSpecCurrency, pContractSpec.CurrencyCode
    .SetSetting ConfigSettingContractSpecExpiry, pContractSpec.Expiry
    .SetSetting ConfigSettingContractSpecMultiplier, pContractSpec.Multiplier
    .SetSetting ConfigSettingContractSpecStrikePrice, pContractSpec.Strike
    .SetSetting ConfigSettingContractSpecRight, gOptionRightToString(pContractSpec.Right)
End With

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Public Sub gSaveContractToConfig(ByVal pContract As IContract, ByVal pConfig As ConfigurationSection)
Const ProcName As String = "gSaveContractToConfig"
On Error GoTo Err

gSaveContractSpecToConfig pContract.Specifier, pConfig.AddConfigurationSection(ConfigSectionContractSpecifier)

With pConfig
    .SetSetting ConfigSettingDaysBeforeExpiryToSwitch, pContract.DaysBeforeExpiryToSwitch
    .SetSetting ConfigSettingDescription, pContract.Description
    .SetSetting ConfigSettingExpiryDate, FormatTimestamp(pContract.ExpiryDate, TimestampDateOnlyISO8601 + TimestampNoMillisecs)
    .SetSetting ConfigSettingSessionEndTime, FormatTimestamp(pContract.SessionEndTime, TimestampTimeOnlyISO8601 + TimestampNoMillisecs)
    .SetSetting ConfigSettingSessionStartTime, FormatTimestamp(pContract.SessionStartTime, TimestampTimeOnlyISO8601 + TimestampNoMillisecs)
    .SetSetting ConfigSettingTickSize, pContract.TickSize
    .SetSetting ConfigSettingTimezoneName, pContract.TimezoneName
End With

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Public Function gSecTypeFromString(ByVal Value As String) As SecurityTypes
Select Case UCase$(Value)
Case "STOCK", "STK"
    gSecTypeFromString = SecTypeStock
Case "FUTURE", "FUT"
    gSecTypeFromString = SecTypeFuture
Case "OPTION", "OPT"
    gSecTypeFromString = SecTypeOption
Case "FUTURES OPTION", "FOP"
    gSecTypeFromString = SecTypeFuturesOption
Case "CASH"
    gSecTypeFromString = SecTypeCash
Case "COMBO", "CMB"
    gSecTypeFromString = SecTypeCombo
Case "INDEX", "IND"
    gSecTypeFromString = SecTypeIndex
End Select
End Function

Public Function gSecTypeToString(ByVal Value As SecurityTypes) As String
Select Case Value
Case SecTypeStock
    gSecTypeToString = "Stock"
Case SecTypeFuture
    gSecTypeToString = "Future"
Case SecTypeOption
    gSecTypeToString = "Option"
Case SecTypeFuturesOption
    gSecTypeToString = "Futures Option"
Case SecTypeCash
    gSecTypeToString = "Cash"
Case SecTypeCombo
    gSecTypeToString = "Combo"
Case SecTypeIndex
    gSecTypeToString = "Index"
End Select
End Function

Public Function gSecTypeToShortString(ByVal Value As SecurityTypes) As String
Select Case Value
Case SecTypeStock
    gSecTypeToShortString = "STK"
Case SecTypeFuture
    gSecTypeToShortString = "FUT"
Case SecTypeOption
    gSecTypeToShortString = "OPT"
Case SecTypeFuturesOption
    gSecTypeToShortString = "FOP"
Case SecTypeCash
    gSecTypeToShortString = "CASH"
Case SecTypeCombo
    gSecTypeToShortString = "CMB"
Case SecTypeIndex
    gSecTypeToShortString = "IND"
End Select
End Function

Public Sub gSetVariant(ByRef pTarget As Variant, ByRef pSource As Variant)
If IsObject(pSource) Then
    Set pTarget = pSource
Else
    pTarget = pSource
End If
End Sub

Public Function gUnEscapeRegexSpecialChar( _
                ByRef inString As String) As String
Dim i As Long
Dim s As String
Dim ch As String
Dim skipNextCheck As Boolean

For i = 1 To Len(inString)
    ch = Mid$(inString, i, 1)
    If skipNextCheck Then
        s = s & ch
        skipNextCheck = False
    Else
        If ch = "\" Then
            skipNextCheck = True
        Else
            s = s & ch
        End If
    End If
Next

gUnEscapeRegexSpecialChar = s
End Function

Public Sub Main()
GPriceParser.gInit
GPriceFormatter.gInit
End Sub

'@================================================================================
' Helper Functions
'@================================================================================

Private Sub addExchangeCode(ByVal Code As String)
Const ProcName As String = "addExchangeCode"

On Error GoTo Err

mMaxExchangeCodesIndex = mMaxExchangeCodesIndex + 1
If mMaxExchangeCodesIndex > UBound(mExchangeCodes) Then
    ReDim Preserve mExchangeCodes(2 * (UBound(mExchangeCodes) + 1) - 1) As String
End If
mExchangeCodes(mMaxExchangeCodesIndex) = UCase$(Code)

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Private Sub addCurrencyDesc( _
                ByVal Code As String, _
                ByVal Description As String)
Const ProcName As String = "addCurrencyDesc"

On Error GoTo Err

mMaxCurrencyDescsIndex = mMaxCurrencyDescsIndex + 1
If mMaxCurrencyDescsIndex > UBound(mCurrencyDescs) Then
    ReDim Preserve mCurrencyDescs(2 * (UBound(mCurrencyDescs) + 1) - 1) As CurrencyDescriptor
End If
mCurrencyDescs(mMaxCurrencyDescsIndex).Code = UCase$(Code)
mCurrencyDescs(mMaxCurrencyDescsIndex).Description = UCase$(Description)

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName
End Sub

Private Function getCurrencyIndex(ByVal Code As String) As Long
Dim bottom As Long
Dim top As Long
Dim middle As Long

Const ProcName As String = "getCurrencyIndex"

On Error GoTo Err

If mMaxCurrencyDescsIndex = 0 Then setupCurrencyDescs

getCurrencyIndex = -1

Code = UCase$(Code)
bottom = 0
top = mMaxCurrencyDescsIndex
middle = Fix((bottom + top) / 2)

Do
    If Code < mCurrencyDescs(middle).Code Then
        top = middle
    ElseIf Code > mCurrencyDescs(middle).Code Then
        bottom = middle
    Else
        getCurrencyIndex = middle
        Exit Function
    End If
    middle = Fix((bottom + top) / 2)
Loop Until bottom = middle

If Code = mCurrencyDescs(middle).Code Then getCurrencyIndex = middle

Exit Function

Err:
gHandleUnexpectedError ProcName, ModuleName
End Function

Private Sub setupExchangeCodes()
Const ProcName As String = "setupExchangeCodes"

On Error GoTo Err

ReDim mExchangeCodes(31) As String
mMaxExchangeCodesIndex = -1

addExchangeCode "ACE"
addExchangeCode "AEB"
addExchangeCode "AMEX"
addExchangeCode "ARCA"
addExchangeCode "ASX"

addExchangeCode "BATS"
addExchangeCode "BELFOX"
addExchangeCode "BEX"
addExchangeCode "BOX"
addExchangeCode "BRUT"
addExchangeCode "BTRADE"
addExchangeCode "BVME"
addExchangeCode "BYX"

addExchangeCode "CAES"
addExchangeCode "CBOE"
addExchangeCode "CBOE2"
addExchangeCode "CBOT"
addExchangeCode "CBSX"
addExchangeCode "CDE"
addExchangeCode "CFE"
addExchangeCode "CHX"
addExchangeCode "CSFBALGO"

addExchangeCode "DRCTEDGE"
addExchangeCode "DTB"

addExchangeCode "EBS"
addExchangeCode "ECBOT"
addExchangeCode "EDGEA"
addExchangeCode "EUREX"
addExchangeCode "EUREXUS"

addExchangeCode "FTA"
addExchangeCode "FWB"

addExchangeCode "GEMINI"
addExchangeCode "GLOBEX"

addExchangeCode "HKFE"

addExchangeCode "IBIS"
addExchangeCode "ICEEU"
addExchangeCode "IDEAL"
addExchangeCode "IDEALPRO"
addExchangeCode "IDEM"
addExchangeCode "IEX"
addExchangeCode "INET"
addExchangeCode "INSTINET"
addExchangeCode "ISE"
addExchangeCode "ISLAND"

addExchangeCode "JEFFALGO"

addExchangeCode "LAVA"
addExchangeCode "LIFFE"
addExchangeCode "LIFFE_NF"
addExchangeCode "LSE"
addExchangeCode "LSEIOB1"
addExchangeCode "LSSF"

addExchangeCode "MATIF"
addExchangeCode "MEFF"
addExchangeCode "MEFFRV"
addExchangeCode "MEXI"
addExchangeCode "MIAX"
addExchangeCode "MONEP"
addExchangeCode "MXT"

addExchangeCode "NASDAQ"
addExchangeCode "NASDAQBX"
addExchangeCode "NASDAQOM"
addExchangeCode "NQLX"
addExchangeCode "NSE"
addExchangeCode "NSX"
addExchangeCode "NYBOT"
addExchangeCode "NYMEX"
addExchangeCode "NYSE"

addExchangeCode "OMS"
addExchangeCode "ONE"
addExchangeCode "OSE.JPN"

addExchangeCode "PHLX"
addExchangeCode "PINK"
addExchangeCode "PSE"
addExchangeCode "PSX"

addExchangeCode "RDBK"

addExchangeCode "SBF"
addExchangeCode "SEHK"
addExchangeCode "SFB"
addExchangeCode "SGX"
addExchangeCode "SMART"
addExchangeCode "SNFE"
addExchangeCode "SOFFEX"
addExchangeCode "SWB"
addExchangeCode "SWX"

addExchangeCode "TPLUS2"
addExchangeCode "TRACKECN"
addExchangeCode "TRQXEN"
addExchangeCode "TSE"
addExchangeCode "TSE.JPN"

addExchangeCode "VENTURE"
addExchangeCode "VIRTX"
addExchangeCode "VWAP"

ReDim Preserve mExchangeCodes(mMaxExchangeCodesIndex) As String

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName

End Sub

Private Sub setupCurrencyDescs()
Const ProcName As String = "setupCurrencyDescs"

On Error GoTo Err

ReDim mCurrencyDescs(127) As CurrencyDescriptor
mMaxCurrencyDescsIndex = -1

addCurrencyDesc "AED", "United Arab Emirates, Dirhams"
addCurrencyDesc "AFN", "Afghanistan, Afghanis"
addCurrencyDesc "ALL", "Albania, Leke"
addCurrencyDesc "AMD", "Armenia, Drams"
addCurrencyDesc "ANG", "Netherlands Antilles, Guilders"
addCurrencyDesc "AOA", "Angola, Kwanza"
addCurrencyDesc "ARS", "Argentina, Pesos"
addCurrencyDesc "AUD", "Australia, Dollars"
addCurrencyDesc "AWG", "Aruba, Guilders"
addCurrencyDesc "AZN", "Azerbaijan, New Manats"
addCurrencyDesc "BAM", "Bosnia and Herzegovina, Convertible Marka"
addCurrencyDesc "BBD", "Barbados, Dollars"
addCurrencyDesc "BDT", "Bangladesh, Taka"
addCurrencyDesc "BGN", "Bulgaria, Leva"
addCurrencyDesc "BHD", "Bahrain, Dinars"
addCurrencyDesc "BIF", "Burundi, Francs"
addCurrencyDesc "BMD", "Bermuda, Dollars"
addCurrencyDesc "BND", "Brunei Darussalam, Dollars"
addCurrencyDesc "BOB", "Bolivia, Bolivianos"
addCurrencyDesc "BRL", "Brazil, Brazil Real"
addCurrencyDesc "BSD", "Bahamas, Dollars"
addCurrencyDesc "BTN", "Bhutan, Ngultrum"
addCurrencyDesc "BWP", "Botswana, Pulas"
addCurrencyDesc "BYR", "Belarus, Rubles"
addCurrencyDesc "BZD", "Belize, Dollars"
addCurrencyDesc "CAD", "Canada, Dollars"
addCurrencyDesc "CDF", "Congo/Kinshasa, Congolese Francs"
addCurrencyDesc "CHF", "Switzerland, Francs"
addCurrencyDesc "CLP", "Chile, Pesos"
addCurrencyDesc "CNY", "China, Yuan Renminbi"
addCurrencyDesc "COP", "Colombia, Pesos"
addCurrencyDesc "CRC", "Costa Rica, Colones"
addCurrencyDesc "CUP", "Cuba, Pesos"
addCurrencyDesc "CVE", "Cape Verde, Escudos"
addCurrencyDesc "CYP", "Cyprus, Pounds"
addCurrencyDesc "CZK", "Czech Republic, Koruny"
addCurrencyDesc "DJF", "Djibouti, Francs"
addCurrencyDesc "DKK", "Denmark, Kroner"
addCurrencyDesc "DOP", "Dominican Republic, Pesos"
addCurrencyDesc "DZD", "Algeria, Algeria Dinars"
addCurrencyDesc "EEK", "Estonia, Krooni"
addCurrencyDesc "EGP", "Egypt, Pounds"
addCurrencyDesc "ERN", "Eritrea, Nakfa"
addCurrencyDesc "ETB", "Ethiopia, Birr"
addCurrencyDesc "EUR", "Euro Member Countries, Euro"
addCurrencyDesc "FJD", "Fiji, Dollars"
addCurrencyDesc "FKP", "Falkland Islands (Malvinas), Pounds"
addCurrencyDesc "GBP", "United Kingdom, Pounds"
addCurrencyDesc "GEL", "Georgia, Lari"
addCurrencyDesc "GGP", "Guernsey, Pounds"
addCurrencyDesc "GHC", "Ghana, Cedis"
addCurrencyDesc "GHS", "Ghana, Cedis"
addCurrencyDesc "GIP", "Gibraltar, Pounds"
addCurrencyDesc "GMD", "Gambia, Dalasi"
addCurrencyDesc "GNF", "Guinea, Francs"
addCurrencyDesc "GTQ", "Guatemala, Quetzales"
addCurrencyDesc "GYD", "Guyana, Dollars"
addCurrencyDesc "HKD", "Hong Kong, Dollars"
addCurrencyDesc "HNL", "Honduras, Lempiras"
addCurrencyDesc "HRK", "Croatia, Kuna"
addCurrencyDesc "HTG", "Haiti, Gourdes"
addCurrencyDesc "HUF", "Hungary, Forint"
addCurrencyDesc "IDR", "Indonesia, Rupiahs"
addCurrencyDesc "ILS", "Israel, New Shekels"
addCurrencyDesc "IMP", "Isle of Man, Pounds"
addCurrencyDesc "INR", "India, Rupees"
addCurrencyDesc "IQD", "Iraq, Dinars"
addCurrencyDesc "IRR", "Iran, Rials"
addCurrencyDesc "ISK", "Iceland, Kronur"
addCurrencyDesc "JEP", "Jersey, Pounds"
addCurrencyDesc "JMD", "Jamaica, Dollars"
addCurrencyDesc "JOD", "Jordan, Dinars"
addCurrencyDesc "JPY", "Japan, Yen"
addCurrencyDesc "KES", "Kenya, Shillings"
addCurrencyDesc "KGS", "Kyrgyzstan, Soms"
addCurrencyDesc "KHR", "Cambodia, Riels"
addCurrencyDesc "KMF", "Comoros, Francs"
addCurrencyDesc "KPW", "Korea (North), Won"
addCurrencyDesc "KRW", "Korea (South), Won"
addCurrencyDesc "KWD", "Kuwait, Dinars"
addCurrencyDesc "KYD", "Cayman Islands, Dollars"
addCurrencyDesc "KZT", "Kazakhstan, Tenge"
addCurrencyDesc "LAK", "Laos, Kips"
addCurrencyDesc "LBP", "Lebanon, Pounds"
addCurrencyDesc "LKR", "Sri Lanka, Rupees"
addCurrencyDesc "LRD", "Liberia, Dollars"
addCurrencyDesc "LSL", "Lesotho, Maloti"
addCurrencyDesc "LTL", "Lithuania, Litai"
addCurrencyDesc "LVL", "Latvia, Lati"
addCurrencyDesc "LYD", "Libya, Dinars"
addCurrencyDesc "MAD", "Morocco, Dirhams"
addCurrencyDesc "MDL", "Moldova, Lei"
addCurrencyDesc "MGA", "Madagascar, Ariary"
addCurrencyDesc "MKD", "Macedonia, Denars"
addCurrencyDesc "MMK", "Myanmar (Burma), Kyats"
addCurrencyDesc "MNT", "Mongolia, Tugriks"
addCurrencyDesc "MOP", "Macau, Patacas"
addCurrencyDesc "MRO", "Mauritania, Ouguiyas"
addCurrencyDesc "MTL", "Malta, Liri"
addCurrencyDesc "MUR", "Mauritius, Rupees"
addCurrencyDesc "MVR", "Maldives (Maldive Islands), Rufiyaa"
addCurrencyDesc "MWK", "Malawi, Kwachas"
addCurrencyDesc "MXN", "Mexico, Pesos"
addCurrencyDesc "MYR", "Malaysia, Ringgits"
addCurrencyDesc "MZN", "Mozambique, Meticais"
addCurrencyDesc "NAD", "Namibia, Dollars"
addCurrencyDesc "NGN", "Nigeria, Nairas"
addCurrencyDesc "NIO", "Nicaragua, Cordobas"
addCurrencyDesc "NOK", "Norway, Krone"
addCurrencyDesc "NPR", "Nepal, Nepal Rupees"
addCurrencyDesc "NZD", "New Zealand, Dollars"
addCurrencyDesc "OMR", "Oman, Rials"
addCurrencyDesc "PAB", "Panama, Balboa"
addCurrencyDesc "PEN", "Peru, Nuevos Soles"
addCurrencyDesc "PGK", "Papua New Guinea, Kina"
addCurrencyDesc "PHP", "Philippines, Pesos"
addCurrencyDesc "PKR", "Pakistan, Rupees"
addCurrencyDesc "PLN", "Poland, Zlotych"
addCurrencyDesc "PYG", "Paraguay, Guarani"
addCurrencyDesc "QAR", "Qatar, Rials"
addCurrencyDesc "RON", "Romania, New Lei"
addCurrencyDesc "RSD", "Serbia, Dinars"
addCurrencyDesc "RUB", "Russia, Rubles"
addCurrencyDesc "RWF", "Rwanda, Rwanda Francs"
addCurrencyDesc "SAR", "Saudi Arabia, Riyals"
addCurrencyDesc "SBD", "Solomon Islands, Dollars"
addCurrencyDesc "SCR", "Seychelles, Rupees"
addCurrencyDesc "SDG", "Sudan, Pounds"
addCurrencyDesc "SEK", "Sweden, Kronor"
addCurrencyDesc "SGD", "Singapore, Dollars"
addCurrencyDesc "SHP", "Saint Helena, Pounds"
addCurrencyDesc "SKK", "Slovakia, Koruny"
addCurrencyDesc "SLL", "Sierra Leone, Leones"
addCurrencyDesc "SOS", "Somalia, Shillings"
addCurrencyDesc "SPL", "Seborga, Luigini"
addCurrencyDesc "SRD", "Suriname, Dollars"
addCurrencyDesc "STD", "S�o Tome and Principe, Dobras"
addCurrencyDesc "SVC", "El Salvador, Colones"
addCurrencyDesc "SYP", "Syria, Pounds"
addCurrencyDesc "SZL", "Swaziland, Emalangeni"
addCurrencyDesc "THB", "Thailand, Baht"
addCurrencyDesc "TJS", "Tajikistan, Somoni"
addCurrencyDesc "TMM", "Turkmenistan, Manats"
addCurrencyDesc "TND", "Tunisia, Dinars"
addCurrencyDesc "TOP", "Tonga, Pa'anga"
addCurrencyDesc "TRY", "Turkey, New Lira"
addCurrencyDesc "TTD", "Trinidad and Tobago, Dollars"
addCurrencyDesc "TVD", "Tuvalu, Tuvalu Dollars"
addCurrencyDesc "TWD", "Taiwan, New Dollars"
addCurrencyDesc "TZS", "Tanzania, Shillings"
addCurrencyDesc "UAH", "Ukraine, Hryvnia"
addCurrencyDesc "UGX", "Uganda, Shillings"
addCurrencyDesc "USD", "United States of America, Dollars"
addCurrencyDesc "UYU", "Uruguay, Pesos"
addCurrencyDesc "UZS", "Uzbekistan, Sums"
addCurrencyDesc "VEB", "Venezuela, Bolivares"
addCurrencyDesc "VND", "Viet Nam, Dong"
addCurrencyDesc "VUV", "Vanuatu, Vatu"
addCurrencyDesc "WST", "Samoa, Tala"
addCurrencyDesc "XAF", "Communaut� Financi�re Africaine BEAC, Francs"
addCurrencyDesc "XAG", "Silver, Ounces"
addCurrencyDesc "XAU", "Gold, Ounces"
addCurrencyDesc "XCD", "East Caribbean Dollars"
addCurrencyDesc "XOF", "Communaut� Financi�re Africaine BCEAO, Francs"
addCurrencyDesc "XPD", "Palladium Ounces"
addCurrencyDesc "XPF", "Comptoirs Fran�ais du Pacifique Francs"
addCurrencyDesc "XPT", "Platinum, Ounces"
addCurrencyDesc "YER", "Yemen, Rials"
addCurrencyDesc "ZAR", "South Africa, Rand"
addCurrencyDesc "ZMK", "Zambia, Kwacha"
addCurrencyDesc "ZWD", "Zimbabwe, Zimbabwe Dollars"


ReDim Preserve mCurrencyDescs(mMaxCurrencyDescsIndex) As CurrencyDescriptor

Exit Sub

Err:
gHandleUnexpectedError ProcName, ModuleName

End Sub
