public with sharing class OpportunityTriggerHelper {
    public static boolean isTriggerRunning = false;

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
            Map<Id, String> mapOfOwnerEmails = new Map<Id, String>();
            for (User user : [SELECT Id, Email FROM User WHERE Id IN :ownerIds WITH SYSTEM_MODE]) {
                mapOfOwnerEmails.put(user.Id, user.Email);
            }   
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
            } catch (Exception e) {
                System.debug('Error when sending email: ' + e.getMessage());
            }
        }

        public static void assignPrimaryContact(Map<Id, Opportunity> oppNewMap) {
        
            Set<Id> accountIds = new Set<Id>();
            for (Opportunity opp : oppNewMap.values()) {
                accountIds.add(opp.AccountId);
            }
                    
            Map<Id, Contact> accountPrimaryContactsMap = new Map<Id, Contact>();
            for (Contact con : [
                SELECT Id, AccountId 
                FROM Contact 
                WHERE Title = 'VP Sales' 
                AND AccountId IN :accountIds WITH SYSTEM_MODE
            ]) {
                accountPrimaryContactsMap.put(con.AccountId, con);
            }
                    
            List<Opportunity> oppsToUpdate = new List<Opportunity>(); 
            for (Opportunity opp : oppNewMap.values()) {
                if (opp.Primary_Contact__c == null) {
                    Contact primaryContact = accountPrimaryContactsMap.get(opp.AccountId);
                    if (primaryContact != null) {
                        Opportunity oppToUpdate = new Opportunity(Id = opp.Id, Primary_Contact__c = primaryContact.Id);
                        oppsToUpdate.add(oppToUpdate);
                    }
                }
            }
                    
            if (!oppsToUpdate.isEmpty()) {
                update as system oppsToUpdate;
            }
        }

        public static void amountValidation(List<Opportunity> newOpps) {
            for (Opportunity opp : newOpps) {
                if (opp.Amount < 5000){
                    opp.addError('Opportunity amount must be greater than 5000');
                }
            }        
        }

        public static void deleteCloseWonOpportunity(List<Opportunity> oldOpps) {
            Set<Id> opportunityIds = new Set<Id>();
            for (Opportunity opp : oldOpps) {
                opportunityIds.add(opp.Id);
            }
    
            List<Opportunity> closedWonOpps = [
                SELECT Id, StageName, AccountId, Account.Industry
                FROM Opportunity
                WHERE StageName = 'Closed Won'
                AND Account.Industry = 'Banking'
                AND Id IN :opportunityIds
                WITH SECURITY_ENFORCED
            ];
    
            for (Opportunity opp : closedWonOpps) {
                opp.addError('Cannot delete closed opportunity for a banking account that is won');
            }
        }

        public static void setPrimaryContact(List<Opportunity> newOpps) {
            Set<Id> accountIds = new Set<Id>();
            for (Opportunity opp : newOpps) {
                accountIds.add(opp.AccountId);
            }

            Map<Id, Contact> accountIdToPrimaryContactMap = new Map<Id, Contact>();
            for (Contact con : [
                SELECT Id, AccountId, Title 
                FROM Contact 
                WHERE Title = 'CEO' 
                AND AccountId IN :accountIds
                WITH SECURITY_ENFORCED 
            ]) {
                accountIdToPrimaryContactMap.put(con.AccountId, con); 
            }
    
            List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
            for (Opportunity opp : newOpps) {
                if (accountIdToPrimaryContactMap.containsKey(opp.AccountId)) {
                    Opportunity updatedOpp = new Opportunity(
                        Id = opp.Id, 
                        Primary_Contact__c = accountIdToPrimaryContactMap.get(opp.AccountId).Id
                    );
                    opportunitiesToUpdate.add(updatedOpp); 
                }
            }
    
            if (!opportunitiesToUpdate.isEmpty()) {
                update as system opportunitiesToUpdate;
            }
        }
}