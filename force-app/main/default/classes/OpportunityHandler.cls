public with sharing class OpportunityHandler extends TriggerHandler{
    public OpportunityHandler() {

    }
    protected override void beforeInsert() {
        List<Opportunity> newOpps = (List<Opportunity>) Trigger.new;
        OpportunityHelper.setType(newOpps);
    }
    protected override void beforeInsert() {
        List<Opportunity> oldOpps = (List<Opportunity>) Trigger.old;
        OpportunityHelper.validateCloseOpportunity(oldOpps);

    }
}