public with sharing class OpportunityTriggerHelper {
    public static void setType(List<Opportunity> opportunities) {
    for (Opportunity opp : opportunities) {
        if (opp.Type == null){
            opp.Type = 'New Customer';
        }
    }
}
    public static void validateCloseOpportunity(List<Opportunity> opportunities) {
        for (Opportunity opp : opportunities) {
                if (opp.IsClosed) {
                    opp.addError('Cannot delete closed opportunity');
                    }
                }
            }

    public static void insertTask(List<Opportunity> newOpps) {
        System.debug('new opps to create tasks: '+ newOpps);
        List<Task> tasksToInsert = new List<Task>();
        for (Opportunity opp : newOpps) {
            Task tsk = new Task();
            tsk.Subject = 'Call Primary Contact';
            tsk.WhatId = opp.Id;
            tsk.WhoId = opp.Primary_Contact__c;
            tsk.OwnerId = opp.OwnerId;
            tsk.ActivityDate = Date.today().addDays(3);
            tasksToInsert.add(tsk);
        }
        insert tasksToInsert;
    }
}
    