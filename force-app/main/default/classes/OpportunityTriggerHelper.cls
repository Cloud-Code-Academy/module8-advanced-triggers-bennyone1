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
        insert as user tasksToInsert;
    }

        public static void updateDescriptionFromStage(List<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap) {
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            for (Opportunity opp : newOpps) {
                Opportunity oldOpp = oldOppMap.get(opp.Id);
                if (opp.StageName != null && oldOpp != null && opp.StageName != oldOpp.StageName) {
                    Opportunity updatedOpp = new Opportunity(Id = opp.Id);
                    if (oldOpp.Description == null) {
                        updatedOpp.Description = ''; 
                    } else {
                        updatedOpp.Description = oldOpp.Description;
                    }
                    updatedOpp.Description += '\n Stage Change:' + opp.StageName + ':' + DateTime.now().format();
                    oppsToUpdate.add(updatedOpp);
                }
            }
            if (!oppsToUpdate.isEmpty()) {
                update as user oppsToUpdate; 
            }
        }

        public static void  notifyOwnersOpportunityDeleted(List<Opportunity> opps) {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            
            Set<Id> ownerIds = new Set<Id>();
            for (Opportunity opp : opps) {
                ownerIds.add(opp.OwnerId);
            }
            System.debug('ownerIds set: ' + ownerIds);
            Map<Id, String> mapOfOwnerEmails = new Map<Id, String>();
            for (User user : [SELECT Id, Email FROM User WHERE Id IN :ownerIds]) {
                mapOfOwnerEmails.put(user.Id, user.Email);
            }   
            System.debug('map of owner emails: ' + mapOfOwnerEmails);
            for (Opportunity opp : opps){
                String ownerEmail = mapOfOwnerEmails.get(opp.OwnerId);
                if (ownerEmail != null) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new String[] { ownerEmail });
                    mail.setSubject('Opportunity Deleted : ' + opp.Name);
                    mail.setPlainTextBody('Your Opportunity: ' + opp.Name +' has been deleted.');
                    mails.add(mail);
                }
            }        
            
            try {
                Messaging.sendEmail(mails);
            } catch (Exception e){
                System.debug('Exception: ' + e.getMessage());
            }
        }
    }