@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Budget Bericht Mittelverteilung ZB'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity /THKR/CDS_BUD_MV_ZB
  as select from    I_BudgetEntryDocument     as BudgetDoc
    left outer join I_BudgetEntryDocumentItem as itemSender on  BudgetDoc.BudgetEntryDocument = itemSender.BudgetEntryDocument
                                                            and BudgetDoc.BudgetVersion = '000'
                                                            and(
                                                              'SEND'                         = itemSender.InternalBudgetingProcess
                                                              or 'TRCS'                      = itemSender.InternalBudgetingProcess
                                                              or 'ENTR'                      = itemSender.InternalBudgetingProcess
                                                            )
  association [0..*] to I_BudgetEntryDocumentItem as itemRecv  on  BudgetDoc.BudgetEntryDocument = itemRecv.BudgetEntryDocument
                                                               and BudgetDoc.BudgetVersion = '000'
                                                               and (
                                                                  'RECV'                         = itemRecv.InternalBudgetingProcess
                                                                  or 'TRCR'                      = itemRecv.InternalBudgetingProcess
                                                                )
  association [0..1] to /THKR/BCS_CVGRP_DESC      as coverGrps on  itemSender.BudgetedFund           = coverGrps.fund
                                                               and itemSender.BudgetedFundsCenter    = coverGrps.fundsctr
                                                               and itemSender.BudgetedCommitmentItem = coverGrps.cmmtitem
                                                               and itemSender.BudgetCategory         = coverGrps.BudgetCat
                                                               and 'M'                               = coverGrps.CvGrpType
{
  key  BudgetDoc.BudgetEntryDocument                   as senderBudgetDocId,
       itemSender.FinMgmtAreaFiscalYear                as senderFiscYear,
       itemSender.BudgetedFund                         as senderFond,
       itemSender.BudgetedFundsCenter                  as senderFundsCenter,
       itemSender.BudgetedCommitmentItem               as senderFipos,
       itemSender.BudgetedFunctionalArea               as senderFuncArea,
       itemSender.BudgetedFundedProgram                as senderHhp,
       itemSender.BudgetType                           as senderBUDGETTYPE,
       itemSender.BudgetCategory,
       coverGrps.text                                  as senderManualCvgrp,
       itemSender.InternalBudgetingProcess,
       @Semantics.amount.currencyCode : 'CURRENCY'
       abs( itemSender.BudgetAmountInTransactionCrcy ) as budget,
       itemRecv.BudgetedFund                           as receiverFund,
       itemRecv.BudgetedFundsCenter                    as receiverFundsCenter,
       itemRecv.BudgetedCommitmentItem                 as receiverFipos,
       itemRecv.BudgetedFunctionalArea                 as receiverFuncArea,
       itemRecv.BudgetedFundedProgram                  as receiverHhp,
       itemRecv.BudgetType                             as receiverBUDGETTYPE,
       itemRecv.InternalBudgetingProcess               as recBudgetingProcess,
       itemSender.TransactionCurrency                  as currency,
       case
            when itemSender.InternalBudgetingProcess =  'SEND'
                or itemSender.InternalBudgetingProcess = 'TRCS'  then 'Sender'
            when itemSender.InternalBudgetingProcess =  'ENTR'  then 'Eingang'
       end                                             as SenderProzess,
       case
            when itemRecv.InternalBudgetingProcess =  'RECV'
                or itemRecv.InternalBudgetingProcess = 'TRCR' then 'Empfänger'
       end                                             as ReceiverProzess,
       itemSender.BdgtCashEffectivityFiscalYear        as BudgetEffectFiscalYear
       //       @Semantics.amount.currencyCode : 'CURRENCY'
       //       sum( itemSender.BudgetAmountInTransactionCrcy ) as amount
}
group by
  BudgetDoc.BudgetEntryDocument,
  itemSender.BudgetedFund,
  itemSender.BudgetedFundsCenter,
  itemSender.BudgetedFund,
  itemSender.BudgetedFundsCenter,
  itemSender.BudgetedCommitmentItem,
  itemSender.BudgetedFunctionalArea,
  itemSender.BudgetedFundedProgram,
  itemSender.BudgetType,
  coverGrps.text,
  itemSender.BudgetAmountInTransactionCrcy,
  itemRecv.BudgetedFund,
  itemRecv.BudgetedFundsCenter,
  itemRecv.BudgetedCommitmentItem,
  itemRecv.BudgetedFunctionalArea,
  itemRecv.BudgetedFundedProgram,
  itemRecv.BudgetType,
  itemRecv.InternalBudgetingProcess,
  itemSender.TransactionCurrency,
  itemSender.InternalBudgetingProcess,
  itemSender.BdgtCashEffectivityFiscalYear,
  itemSender.BudgetCategory,
  itemSender.FinMgmtAreaFiscalYear
