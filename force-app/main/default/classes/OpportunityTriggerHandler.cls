public with sharing class OpportunityTriggerHandler extends TriggerHandler{
    
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
}