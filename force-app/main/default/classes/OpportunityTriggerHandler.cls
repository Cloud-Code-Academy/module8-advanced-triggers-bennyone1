public with sharing class OpportunityTriggerHandler extends TriggerHandler {

    @TestVisible
    protected virtual override void beforeInsert() {
        List<Opportunity> newOpps = (List<Opportunity>) Trigger.new;
        OpportunityTriggerHelper.setType(newOpps);
    }
    @TestVisible
    protected override void beforeDelete() {
        List<Opportunity> oldOpps = (List<Opportunity>) Trigger.old;
        OpportunityTriggerHelper.validateCloseOpportunity(oldOpps);
        OpportunityTriggerHelper.deleteCloseWonOpportunity(oldOpps);

    }
    @TestVisible
    protected override void afterInsert() {
        List<Opportunity> newOpps = (List<Opportunity>) Trigger.new;
        OpportunityTriggerHelper.insertTask(newOpps);
    }

    @TestVisible
    protected override void afterUpdate() {
        if (!OpportunityTriggerHelper.isTriggerRunning) {
            OpportunityTriggerHelper.isTriggerRunning = true;
            try {
                List<Opportunity> newOpps = (List<Opportunity>) Trigger.new;
                Map<Id, Opportunity> oldOppMap = (Map<Id, Opportunity>) Trigger.oldMap;
                OpportunityTriggerHelper.updateDescriptionFromStage(newOpps, oldOppMap);
                OpportunityTriggerHelper.amountValidation(newOpps);
                OpportunityTriggerHelper.setPrimaryContact(newOpps);
            } finally {
                OpportunityTriggerHelper.isTriggerRunning = false;
            }
        }
    }

    @TestVisible
    protected override void afterDelete() {
        List<Opportunity> oldOpps = (List<Opportunity>) Trigger.old;
        OpportunityTriggerHelper.notifyOwnersOpportunityDeleted(oldOpps);
    }

    @TestVisible
    protected override void afterUndelete() {
        Map<Id, Opportunity> oldOppMap = (Map<Id, Opportunity>) Trigger.newMap;
        OpportunityTriggerHelper.assignPrimaryContact(oldOppMap);
    }
}
