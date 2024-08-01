public with sharing class OpportunityTriggerHandler extends TriggerHandler {
   /* private Map<Id, Opportunity> newMap;
    private Map<Id, Opportunity> oldMap;

    public OpportunityTriggerHandler(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        this.newMap = newMap;
        this.oldMap = oldMap;
    }

    public override void run() {
        if (Trigger.isBefore && Trigger.isInsert) {
            beforeInsert();
        } else if (Trigger.isAfter && Trigger.isInsert) {
            afterInsert();
        } else if (Trigger.isBefore && Trigger.isUpdate) {
            beforeUpdate();
        } else if (Trigger.isAfter && Trigger.isUpdate) {
            afterUpdate();
        } else if (Trigger.isBefore && Trigger.isDelete) {
            beforeDelete();
        } else if (Trigger.isAfter && Trigger.isDelete) {
            afterDelete();
        } else if (Trigger.isAfter && Trigger.isUndelete) {
            afterUndelete();
        }
    }*/

    @TestVisible
    protected virtual override void beforeInsert() {
        List<Opportunity> newOpps = (List<Opportunity>) Trigger.new;
        OpportunityTriggerHelper.setType(newOpps);
    }
    @TestVisible
    protected override void beforeDelete() {
        List<Opportunity> oldOpps = (List<Opportunity>) Trigger.old;
        OpportunityTriggerHelper.validateCloseOpportunity(oldOpps);

    }
    @TestVisible
    protected override void afterInsert() {
        List<Opportunity> newOpps = (List<Opportunity>) Trigger.new;
        OpportunityTriggerHelper.insertTask(newOpps);
    }

    @TestVisible
    protected override void afterUpdate() {
        List<Opportunity> newOpps = (List<Opportunity>) Trigger.new;
        Map<Id, Opportunity> oldOppMap = (Map<Id, Opportunity>) Trigger.oldMap;
        OpportunityTriggerHelper.updateDescriptionFromStage(newOpps, oldOppMap);
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
